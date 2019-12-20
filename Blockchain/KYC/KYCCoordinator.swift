//
//  KYCCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import NetworkKit
import PlatformKit
import PlatformUIKit

enum KYCEvent {

    /// When a particular screen appears, we need to
    /// look at the `NabuUser` object and determine if
    /// there is data there for pre-populate the screen with.
    case pageWillAppear(KYCPageType)

    /// This will push on the next page in the KYC flow.
    case nextPageFromPageType(KYCPageType, KYCPagePayload?)

    /// Event emitted when the provided page type emits an error
    case failurePageForPageType(KYCPageType, KYCPageError)
}

protocol KYCCoordinatorDelegate: class {
    func apply(model: KYCPageModel)
}

/// Coordinates the KYC flow. This component can be used to start a new KYC flow, or if
/// the user drops off mid-KYC and decides to continue through it again, the coordinator
/// will handle recovering where they left off.
@objc class KYCCoordinator: NSObject, Coordinator {

    // MARK: - Public Properties

    weak var delegate: KYCCoordinatorDelegate?

    static let shared = KYCCoordinator()

    @objc class func sharedInstance() -> KYCCoordinator {
        return KYCCoordinator.shared
    }

    // MARK: - Private Properties

    private(set) var user: NabuUser?

    private(set) var country: KYCCountry?

    private var pager: KYCPagerAPI!

    private weak var rootViewController: UIViewController?

    private var navController: KYCOnboardingNavigationController!

    private let disposables = CompositeDisposable()

    private let disposeBag = DisposeBag()
    
    private let pageFactory = KYCPageViewFactory()

    private let appSettings: BlockchainSettings.App
    private let authenticationService: NabuAuthenticationService
    private let loadingViewPresenter: LoadingViewPresenting
    
    private var userTiersResponse: KYCUserTiersResponse?
    private var kycSettings: KYCSettingsAPI
    
    private let blockchainRepository: BlockchainDataRepository
    private let communicator: NetworkCommunicatorAPI

    private let webViewServiceAPI: WebViewServiceAPI
    
    init(
        webViewServiceAPI: WebViewServiceAPI = UIApplication.shared,
        blockchainRepository: BlockchainDataRepository = .shared,
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        kycSettings: KYCSettingsAPI = KYCSettings.shared,
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
        communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared
    ) {
        self.webViewServiceAPI = webViewServiceAPI
        self.blockchainRepository = blockchainRepository
        self.appSettings = appSettings
        self.kycSettings = kycSettings
        self.authenticationService = authenticationService
        self.loadingViewPresenter = loadingViewPresenter
        self.communicator = communicator
    }

    deinit {
        disposables.dispose()
    }

    // MARK: Public
    
    func start() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        start(from: rootViewController)
    }

    func startFrom(_ tier: KYCTier = .tier1) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        
        start(from: rootViewController, tier: tier)
    }
    
    /// Presents an airdrop modal before bringing the user to KYC
    func startKycForSTXAirdrop(from parentViewController: UIViewController, tier: KYCTier = .tier1) {
        // In case the user has started KYC for STX airdrop, register for the KYC completion
        registerForBlockstackAirdropKycCompletion()
        let viewController = NavigationController()
        let presenter = InfoScreenPresenter(
            with: AirdropInfoScreenContent(),
            action: { [weak self] in
                parentViewController.dismiss(animated: true) {
                    self?.start(from: parentViewController, tier: tier)
                }
            }
        )
        presenter.disclaimerViewModel.tap
            .bind { [weak self, weak viewController] titledUrl in
                guard let self = self, let viewController = viewController else { return }
                self.webViewServiceAPI.openSafari(url: titledUrl.url, from: viewController)
            }
            .disposed(by: disposeBag)
        viewController.viewControllers = [InfoScreenViewController(presenter: presenter)]
        if #available(iOS 13.0, *) {
            viewController.modalPresentationStyle = .automatic
        }
        parentViewController.present(viewController, animated: true, completion: nil)
    }
        
    private func showKycCompletionForBlockstackAirdrop() {
        guard let parentViewController = rootViewController else {
            Logger.shared.error("Trying to display KYC completion while `rootViewController` is `nil`")
            return
        }
        let presenter = InfoScreenPresenter(
            with: STXApplicationCompleteInfoScreenContent(),
            action: {
                parentViewController.dismiss(animated: true) { [weak parentViewController] in
                    // TODO: this will be added back once the url is live
                    // let url = URL(string: Constants.Url.airdropWaitlist)!
                    let message = LocalizationConstants.InfoScreen.STXApplicationComplete.shareText
                    // TODO: this will be changed back once the url is live
                    // let activityItems = [ url, message ]
                    let activityItems = [ message ]
                    let activityVC = UIActivityViewController(
                        activityItems: activityItems,
                        applicationActivities: nil
                    )
                    parentViewController?.present(activityVC, animated: true)
                }
            }
        )
        let viewController = NavigationController(
            rootViewController: InfoScreenViewController(presenter: presenter)
        )
        if #available(iOS 13.0, *) {
            viewController.modalPresentationStyle = .automatic
        }
        parentViewController.present(viewController, animated: true, completion: nil)
    }
        
    private func registerForBlockstackAirdropKycCompletion() {
        NotificationCenter.when(Constants.NotificationKeys.kycStopped) { [weak self] _ in
            guard let self = self else { return }
            self.blockchainRepository.tiers
                .take(1)
                .asSingle()
                .map { $0.isTier2Pending }
                .catchErrorJustReturn(false)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] isEligible in
                    guard let self = self, isEligible else { return }
                    self.showKycCompletionForBlockstackAirdrop()
                })
                .disposed(by: self.disposeBag)
        }
    }

    func start(from viewController: UIViewController, tier: KYCTier = .tier1) {
        rootViewController = viewController
        AnalyticsService.shared.trackEvent(title: tier.startAnalyticsKey)
        
        loadingViewPresenter.show(with: LocalizationConstants.loading)
        let postTierObservable = post(tier: tier).asObservable()
        let userObservable = BlockchainDataRepository.shared.fetchNabuUser().asObservable()
        
        let disposable = Observable.zip(userObservable, postTierObservable)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .hideLoaderOnDisposal(loader: loadingViewPresenter)
            .subscribe(onNext: { [weak self] (user, tiersResponse) in
                self?.pager = KYCPager(tier: tier, tiersResponse: tiersResponse)
                Logger.shared.debug("Got user with ID: \(user.personalDetails?.identifier ?? "")")
                guard let strongSelf = self else {
                    return
                }
                strongSelf.userTiersResponse = tiersResponse
                strongSelf.user = user
                
                let startingPage = user.isSunriverAirdropRegistered == true ?
                    KYCPageType.welcome :
                    KYCPageType.startingPage(forUser: user, tiersResponse: tiersResponse)
                if startingPage != .accountStatus {
                    /// If the starting page is accountStatus, they do not have any additional
                    /// pages to view, so we don't want to set `isCompletingKyc` to `true`.
                    strongSelf.kycSettings.isCompletingKyc = true
                }
                
                strongSelf.initializeNavigationStack(viewController, user: user, tier: tier)
                strongSelf.restoreToMostRecentPageIfNeeded(tier: tier)
            }, onError: { error in
                Logger.shared.error("Failed to get user: \(error.localizedDescription)")
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    // Called when the entire KYC process has been completed.
    @objc func finish() {
        stop()
    }

    // Called when the KYC process is completed or stopped before completing.
    @objc func stop() {
        if navController == nil { return }
        navController.dismiss(animated: true) {
            NotificationCenter.default.post(
                name: Constants.NotificationKeys.kycStopped,
                object: nil
            )
        }
    }

    func handle(event: KYCEvent) {
        switch event {
        case .pageWillAppear(let type):
            handlePageWillAppear(for: type)
        case .failurePageForPageType(_, let error):
            handleFailurePage(for: error)
        case .nextPageFromPageType(let type, let payload):
            handlePayloadFromPageType(type, payload)
            let disposable = pager.nextPage(from: type, payload: payload)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] nextPage in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    let controller = strongSelf.pageFactory.createFrom(
                        pageType: nextPage,
                        in: strongSelf,
                        payload: payload
                    )
                    
                    if let informationController = controller as? KYCInformationController, nextPage == .accountStatus {
                        self?.presentInformationController(informationController)
                        return
                    }
                    
                    strongSelf.navController.pushViewController(controller, animated: true)
                }, onError: { error in
                    Logger.shared.error("Error getting next page: \(error.localizedDescription)")
                }, onCompleted: { [weak self] in
                    Logger.shared.info("No more next pages")
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.kycSettings.isCompletingKyc = false
                    strongSelf.finish()
                })
            disposables.insertWithDiscardableResult(disposable)
        }
    }

    func presentInformationController(_ controller: KYCInformationController) {
        /// Refresh the user's tiers to get their status.
        /// Sometimes we receive an `INTERNAL_SERVER_ERROR` if we refresh this
        /// immediately after submitting all KYC data. So, we apply a delay here.
        loadingViewPresenter.show(with: LocalizationConstants.loading)
        let disposable = BlockchainDataRepository.shared.tiers
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .delay(3.0, scheduler: MainScheduler.instance)
            .hideLoaderOnDisposal(loader: loadingViewPresenter)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                let status = response.tier2AccountStatus
                
                let isReceivingAirdrop = self.user?.isSunriverAirdropRegistered == true
                controller.viewModel = KYCInformationViewModel.create(
                    for: status,
                    isReceivingAirdrop: isReceivingAirdrop
                )
                controller.viewConfig = KYCInformationViewConfig.create(
                    for: status,
                    isReceivingAirdrop: isReceivingAirdrop
                )
                controller.primaryButtonAction = { viewController in
                    switch status {
                    case .approved:
                        self.finish()
                    case .pending:
                        // TODO: Temporary replacement for previous logic.
                        // Once notification permission is redesigned - remove this entirely and
                        // implement properly.
                        RemoteNotificationServiceContainer.default.authorizer
                            .requestAuthorizationIfNeeded()
                            .subscribe()
                            .disposed(by: self.disposeBag)
                    case .failed, .expired:
                        URL(string: Constants.Url.blockchainSupport)?.launch()
                    case .none, .underReview: return
                    }
                }
                
                self.navController.pushViewController(controller, animated: true)
                }, onError: ({ error in
                    Logger.shared.error("Error refreshing tiers status: \(error.localizedDescription)")
                }))
        disposables.insertWithDiscardableResult(disposable)
    }

    // MARK: View Restoration

    /// Restores the user to the most recent page if they dropped off mid-flow while KYC'ing
    private func restoreToMostRecentPageIfNeeded(tier: KYCTier) {
        guard let currentUser = user else {
            return
        }
        guard let response = userTiersResponse else { return }
        
        let latestPage = kycSettings.latestKycPage

        let startingPage = KYCPageType.startingPage(forUser: currentUser, tiersResponse: response)
        
        if startingPage == .accountStatus {
            /// The `tier` on KYCPager cannot be `tier1` if the user's `startingPage` is `.accountStatus`.
            /// If their `startingPage` is `.accountStatus`, they're done.
            pager = KYCPager(tier: .tier2, tiersResponse: response)
        }

        guard let endPageForLastUsedTier = KYCPageType.pageType(
            for: currentUser,
            tiersResponse: response,
            latestPage: latestPage
            ) else {
            return
        }

        // If a user has moved to a new tier, they need to use the starting page for the new tier
        let endPage = endPageForLastUsedTier.rawValue >= startingPage.rawValue ? endPageForLastUsedTier : startingPage

        var currentPage = startingPage
        while currentPage != endPage {
            guard let nextPage = currentPage.nextPage(
                forTier: tier,
                user: user,
                country: country,
                tiersResponse: response
                ) else { return }

            currentPage = nextPage

            let nextController = pageFactory.createFrom(
                pageType: currentPage,
                in: self,
                payload: createPagePayload(page: currentPage, user: currentUser)
            )

            navController.pushViewController(nextController, animated: false)
        }
    }

    private func createPagePayload(page: KYCPageType, user: NabuUser) -> KYCPagePayload? {
        switch page {
        case .confirmPhone:
            return .phoneNumberUpdated(phoneNumber: user.mobile?.phone ?? "")
        case .confirmEmail:
            return .emailPendingVerification(email: user.email.address)
        case .accountStatus:
            guard let response = userTiersResponse else { return nil }
            return .accountStatus(
                status: response.tier2AccountStatus,
                isReceivingAirdrop: user.isSunriverAirdropRegistered == true
            )
        case .enterEmail,
             .welcome,
             .country,
             .states,
             .profile,
             .address,
             .tier1ForcedTier2,
             .enterPhone,
             .verifyIdentity,
             .resubmitIdentity,
             .applicationComplete:
            return nil
        }
    }

    private func initializeNavigationStack(_ viewController: UIViewController, user: NabuUser, tier: KYCTier) {
        guard let response = userTiersResponse else { return }
        let startingPage = user.isSunriverAirdropRegistered == true ?
            KYCPageType.welcome :
            KYCPageType.startingPage(forUser: user, tiersResponse: response)
        var controller: KYCBaseViewController
        if startingPage == .accountStatus {
            controller = pageFactory.createFrom(
                pageType: startingPage,
                in: self,
                payload: .accountStatus(
                    status: response.tier2AccountStatus,
                    isReceivingAirdrop: user.isSunriverAirdropRegistered == true
                )
            )
        } else {
            controller = pageFactory.createFrom(
                pageType: startingPage,
                in: self
            )
        }
        
        navController = presentInNavigationController(controller, in: viewController)
    }

    // MARK: Private Methods

    private func handlePayloadFromPageType(_ pageType: KYCPageType, _ payload: KYCPagePayload?) {
        guard let payload = payload else { return }
        switch payload {
        case .countrySelected(let country):
            self.country = country
        case .phoneNumberUpdated,
             .emailPendingVerification,
             .accountStatus:
            // Not handled here
            return
        }
    }

    private func handleFailurePage(for error: KYCPageError) {

        let informationViewController = KYCInformationController.make(with: self)
        informationViewController.viewConfig = KYCInformationViewConfig(
            titleColor: UIColor.gray5,
            isPrimaryButtonEnabled: true,
            imageTintColor: nil
        )

        switch error {
        case .countryNotSupported(let country):
            kycSettings.isCompletingKyc = false
            informationViewController.viewModel = KYCInformationViewModel.createForUnsupportedCountry(country)
            informationViewController.primaryButtonAction = { [unowned self] viewController in
                viewController.presentingViewController?.presentingViewController?.dismiss(animated: true)
                let interactor = KYCCountrySelectionInteractor()
                let disposable = interactor.selected(
                    country: country,
                    shouldBeNotifiedWhenAvailable: true
                )
                self.disposables.insertWithDiscardableResult(disposable)
            }
            presentInNavigationController(informationViewController, in: navController)
        case .stateNotSupported(let state):
            kycSettings.isCompletingKyc = false
            informationViewController.viewModel = KYCInformationViewModel.createForUnsupportedState(state)
            informationViewController.primaryButtonAction = { [unowned self] viewController in
                viewController.presentingViewController?.presentingViewController?.dismiss(animated: true)
                let interactor = KYCCountrySelectionInteractor()
                let disposable = interactor.selected(
                    state: state,
                    shouldBeNotifiedWhenAvailable: true
                )
                self.disposables.insertWithDiscardableResult(disposable)
            }
            presentInNavigationController(informationViewController, in: navController)
        }
    }

    private func handlePageWillAppear(for type: KYCPageType) {
        if type == .accountStatus || type == .applicationComplete {
            kycSettings.latestKycPage = nil
        } else {
            kycSettings.latestKycPage = type
        }

        // Optionally apply page model
        switch type {
        case .tier1ForcedTier2,
             .welcome,
             .confirmEmail,
             .country,
             .states,
             .accountStatus,
             .applicationComplete,
             .resubmitIdentity:
            break
        case .enterEmail:
            guard let current = user else { return }
            delegate?.apply(model: .email(current))
        case .profile:
            guard let current = user else { return }
            delegate?.apply(model: .personalDetails(current))
        case .address:
            guard let current = user else { return }
            delegate?.apply(model: .address(current, country))
        case .enterPhone, .confirmPhone:
            guard let current = user else { return }
            delegate?.apply(model: .phone(current))
        case .verifyIdentity:
            guard let countryCode = country?.code ?? user?.address?.countryCode else { return }
            delegate?.apply(model: .verifyIdentity(countryCode: countryCode))
        }
    }
    
    private func post(tier: KYCTier) -> Single<KYCUserTiersResponse> {
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
        return authenticationService.getSessionToken().flatMap(weak: self) { (self, token) -> Single<KYCUserTiersResponse> in
            return self.communicator.perform(
                request: NetworkRequest(
                    endpoint: endpoint,
                    method: .post,
                    body: try? JSONEncoder().encode(body),
                    headers: [HttpHeaderField.authorization: token.token]
                )
            )
        }
    }

    @discardableResult private func presentInNavigationController(
        _ viewController: UIViewController,
        in presentingViewController: UIViewController
    ) -> KYCOnboardingNavigationController {
        let navController = KYCOnboardingNavigationController.make()
        navController.pushViewController(viewController, animated: false)
        navController.modalTransitionStyle = .coverVertical
        presentingViewController.present(navController, animated: true)
        return navController
    }
}

fileprivate extension KYCPageType {

    /// The page type the user should be placed in given the information they have provided
    static func pageType(for user: NabuUser, tiersResponse: KYCUserTiersResponse, latestPage: KYCPageType? = nil) -> KYCPageType? {
        // Note: latestPage is only used by tier 2 flow, for tier 1, we need to infer the page,
        // because the user may need to select the country again.
        let tier = user.tiers?.selected ?? .tier1
        switch tier {
        case .tier0:
            return nil
        case .tier1:
            return tier1PageType(for: user)
        case .tier2:
            return tier1PageType(for: user) ?? tier2PageType(for: user, tiersResponse: tiersResponse, latestPage: latestPage)
        }
    }

    private static func tier1PageType(for user: NabuUser) -> KYCPageType? {
        guard user.email.verified else {
            return .enterEmail
        }

        guard let personalDetails = user.personalDetails, personalDetails.firstName != nil else {
            return .country
        }

        guard user.address != nil else { return .country }

        return nil
    }

    private static func tier2PageType(for user: NabuUser, tiersResponse: KYCUserTiersResponse, latestPage: KYCPageType? = nil) -> KYCPageType? {
        if let latestPage = latestPage {
            return latestPage
        }

        guard let mobile = user.mobile else { return .enterPhone }

        guard mobile.verified else { return .confirmPhone }
        
        if tiersResponse.canCompleteTier2 {
            switch tiersResponse.canCompleteTier2 {
            case true:
                return user.needsDocumentResubmission == nil ? .verifyIdentity : .resubmitIdentity
            case false:
                return nil
            }
        }
        
        guard tiersResponse.canCompleteTier2 == false else { return .verifyIdentity }

        return nil
    }
}
