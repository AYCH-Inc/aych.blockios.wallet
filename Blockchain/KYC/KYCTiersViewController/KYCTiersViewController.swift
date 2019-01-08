//
//  KYCTiersViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import SafariServices
import UIKit
import RxSwift

protocol KYCTiersInterface: class {
    func apply(_ model: KYCTiersPageModel)
    func loadingIndicator(_ visibility: Visibility)
    func collectionViewVisibility(_ visibility: Visibility)
}

class KYCTiersViewController: UIViewController {
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var layout: UICollectionViewFlowLayout!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    // MARK: Private Properties
    
    fileprivate static let limitsAPI: TradeLimitsAPI = ExchangeServices().tradeLimits
    fileprivate var authenticationService: NabuAuthenticationService!
    fileprivate var layoutAttributes: LayoutAttributes = .tiersOverview
    fileprivate var coordinator: KYCTiersCoordinator!
    fileprivate var disposable: Disposable?

    // MARK: Public Properties
    
    var pageModel: KYCTiersPageModel!
    
    static func make(
        with pageModel: KYCTiersPageModel,
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared
    ) -> KYCTiersViewController {
        let controller = KYCTiersViewController.makeFromStoryboard()
        controller.pageModel = pageModel
        controller.authenticationService = authenticationService
        return controller
    }
    
    // MARK: Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
        disposable?.dispose()
        disposable = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = KYCTiersCoordinator(interface: self)
        setupLayout()
        registerCells()
        registerSupplementaryViews()
        registerForNotifications()
        collectionView.reloadData()
        pageModel.trackPresentation()
        
        if let navController = navigationController as? BCNavigationController {
            navController.headerLabel.text = LocalizationConstants.KYC.swapLimits
        }
        if let navController = navigationController as? SettingsNavigationController {
            navController.headerLabel.text = LocalizationConstants.KYC.swapLimits
        }
    }
    
    fileprivate func setupLayout() {
        guard let layout = layout else { return }
        
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
    }
    
    fileprivate func registerCells() {
        guard let collection = collectionView else { return }
        collection.delegate = self
        collection.dataSource = self
        
        let nib = UINib(nibName: KYCTierCell.identifier, bundle: nil)
        collection.register(nib, forCellWithReuseIdentifier: KYCTierCell.identifier)
    }
    
    fileprivate func registerSupplementaryViews() {
        guard let collection = collectionView else { return }
        let header = UINib(nibName: pageModel.header.identifier, bundle: nil)
        let footer = UINib(nibName: KYCTiersFooterView.identifier, bundle: nil)
        collection.register(
            header,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: pageModel.header.identifier
        )
        collection.register(
            footer,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: KYCTiersFooterView.identifier
        )
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.when(Constants.NotificationKeys.kycComplete) { [weak self] _ in
            guard let this = self else { return }
            let currencyCode = BlockchainSettings.App.shared.fiatCurrencySymbol
            this.coordinator.refreshViewModel(
                withCurrencyCode: currencyCode,
                suppressCTA: this.pageModel.header.suppressDismissCTA
            )
        }
    }
}

extension KYCTiersViewController: KYCTiersHeaderViewDelegate {
    func headerView(_ view: KYCTiersHeaderView, actionTapped: KYCTiersHeaderViewModel.Action) {
        switch actionTapped {
        case .contactSupport:
            guard let supportURL = URL(string: Constants.Url.blockchainSupportRequest) else { return }
            let controller = SFSafariViewController(url: supportURL)
            present(controller, animated: true, completion: nil)
        case .learnMore:
            guard let verificationURL = URL(string: Constants.Url.verificationRejectedURL) else { return }
            let controller = SFSafariViewController(url: verificationURL)
            present(controller, animated: true, completion: nil)
        case .swapNow:
            /// This isn't pretty but, we only use the custom transition when presenting
            /// tiers from the exchange screen. Outside of that, the only other place where we use
            /// the tiers screen is in settings.
            if transitioningDelegate != nil {
                dismiss(animated: true, completion: nil)
            } else {
                /// Tiers is pushed on when presented from settings. If they go through KYC and are
                /// approved for either tier, there will be a `Swap Now` button in the header. If they
                /// tap this button, we need to pop to root (back to settings) and then resume the
                /// `ExchangeCoordinator` using settings as the root. That will display the exchange.
                guard let navController = navigationController else { return }
                navController.popToRootViewControllerWithHandler {
                    guard let root = navController.viewControllers.first else { return }
                    ExchangeCoordinator.shared.start(rootViewController: root)
                }
            }
        }
    }
    
    func dismissButtonTapped(_ view: KYCTiersHeaderView) {
        dismiss(animated: true, completion: nil)
    }
}

extension KYCTiersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageModel.cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = pageModel.cells[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: KYCTierCell.identifier,
            for: indexPath) as? KYCTierCell else {
                return UICollectionViewCell()
        }
        cell.delegate = self
        cell.configure(with: item)
        return cell
    }
}

extension KYCTiersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = pageModel.cells[indexPath.row]
        guard let cell = collectionView.cellForItem(at: indexPath) as? KYCTierCell else { return }
        guard item.status == .none else {
            Logger.shared.debug(
                """
                Not presenting KYC. KYC should only be presented if the status is `.none` for \(item.tier.tierDescription).
                The status is: \(item.status)
                """
            )
            return
        }
        tierCell(cell, selectedTier: item.tier)
    }
}

extension KYCTiersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = pageModel.cells[indexPath.row]
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        let height = KYCTierCell.heightForProposedWidth(width, model: model)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind
        kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            guard let disclaimer = pageModel.disclaimer else { return UICollectionReusableView() }
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: KYCTiersFooterView.identifier,
                for: indexPath
                ) as? KYCTiersFooterView else { return UICollectionReusableView() }
            footer.configure(with: disclaimer)
            return footer
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: pageModel.header.identifier,
                for: indexPath
                ) as? KYCTiersHeaderView else { return UICollectionReusableView() }
            header.configure(with: pageModel.header)
            header.delegate = self
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
        let height = pageModel.header.estimatedHeight(
            for: collectionView.bounds.width,
            model: pageModel.header
        )
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
        ) -> CGSize {
        guard let disclaimer = pageModel.disclaimer else { return .zero }
        let height = KYCTiersFooterView.estimatedHeight(
            for: disclaimer,
            width: collectionView.bounds.width
        )
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        return CGSize(width: width, height: height)
    }
}

extension KYCTiersViewController: KYCTierCellDelegate {
    func tierCell(_ cell: KYCTierCell, selectedTier: KYCTier) {
        disposable?.dispose()
        disposable = post(tier: selectedTier)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                guard let strongSelf = self else { return }
                AnalyticsService.shared.trackEvent(title: selectedTier.startAnalyticsKey)
                KYCCoordinator.shared.start(from: strongSelf, tier: selectedTier)
            }, onError: { error in
                Logger.shared.error(error.localizedDescription)
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Swap.postTierError)
            })
    }
}

extension KYCTiersViewController: KYCTiersInterface {
    func apply(_ model: KYCTiersPageModel) {
        pageModel = model
        registerSupplementaryViews()
        collectionView.reloadData()
        pageModel.trackPresentation()
    }
    
    func collectionViewVisibility(_ visibility: Visibility) {
        collectionView.alpha = visibility.defaultAlpha
    }
    
    func loadingIndicator(_ visibility: Visibility) {
        switch visibility {
        case .visible:
            LoadingViewPresenter.shared.showBusyView(
                withLoadingText: LocalizationConstants.loading
            )
        case .hidden,
             .translucent:
            LoadingViewPresenter.shared.hideBusyView()
        }
    }
}

extension KYCTiersViewController {
    typealias CurrencyCode = String
    static func routeToTiers(
        fromViewController: UIViewController,
        code: CurrencyCode = "USD"
    ) -> Disposable {

        let tradesObservable = limitsAPI.getTradeLimits(withFiatCurrency: code)
            .optional()
            .catchErrorJustReturn(nil)
            .asObservable() 
        return Observable.zip(
            BlockchainDataRepository.shared.tiers,
            tradesObservable
            )
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                let userTiers = response.0.userTiers
                let limits = response.1
                let formatter: NumberFormatter = NumberFormatter.localCurrencyFormatterWithGroupingSeparator
                let max = NSDecimalNumber(decimal: limits?.maxPossibleOrder ?? 0)
                
                /// Sometimes design wants to suppress the chevron that is shown in both
                /// of the `KYCTiersHeaderViews` (there are two of them). We only show this
                /// when there is a custom transition (like while in the exchange).
                let suppressDismissalCTA = fromViewController is UIViewControllerTransitioningDelegate == false
                
                let header = KYCTiersHeaderViewModel.make(
                    with: response.0,
                    availableFunds: formatter.string(from: max),
                    suppressDismissCTA: suppressDismissalCTA
                )
                let filtered = userTiers.filter({ $0.tier != .tier0 })
                let cells = filtered.map({ return KYCTierCellModel.model(from: $0) }).compactMap({ return $0 })
                
                let page = KYCTiersPageModel(header: header, cells: cells)
                let controller = KYCTiersViewController.make(with: page)
                if let from = fromViewController as? UIViewControllerTransitioningDelegate {
                    controller.transitioningDelegate = from
                }
                if suppressDismissalCTA {
                    if let navController = fromViewController.navigationController {
                        navController.pushViewController(controller, animated: true)
                    } else {
                        let navController = BCNavigationController(rootViewController: controller)
                        fromViewController.present(navController, animated: true, completion: nil)
                    }
                } else {
                    fromViewController.present(controller, animated: true, completion: nil)
                }
            })
    }
}

extension KYCTiersViewController {
    func post(tier: KYCTier) -> Single<KYCUserTiersResponse> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(TradeExecutionAPIError.generic)
        }
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["kyc", "tiers"],
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }
        let body = KYCTierPostBody(selectedTier:tier)
        return authenticationService.getSessionToken().flatMap { token in
            return NetworkRequest.POST(
                url: endpoint,
                body: try? JSONEncoder().encode(body),
                type: KYCUserTiersResponse.self,
                headers: [HttpHeaderField.authorization: token.token]
            )
        }
    }
}
