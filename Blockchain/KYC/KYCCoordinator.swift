//
//  KYCCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

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

    fileprivate var navController: KYCOnboardingNavigationController!

    private let disposables = CompositeDisposable()

    private let pageFactory = KYCPageViewFactory()

    private let appSettings: BlockchainSettings.App

    private var kycSettings: KYCSettingsAPI

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        kycSettings: KYCSettingsAPI = KYCSettings.shared
    ) {
        self.appSettings = appSettings
        self.kycSettings = kycSettings
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

    func start(from viewController: UIViewController, tier: KYCTier = .tier1) {
        pager = KYCPager(tier: tier)
        rootViewController = viewController

        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.loading)

        let disposable = BlockchainDataRepository.shared.fetchNabuUser()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .do(onDispose: { LoadingViewPresenter.shared.hideBusyView() })
            .subscribe(onSuccess: { [weak self] in
                Logger.shared.debug("Got user with ID: \($0.personalDetails?.identifier ?? "")")
                guard let strongSelf = self else {
                    return
                }
                strongSelf.kycSettings.isCompletingKyc = true
                strongSelf.user = $0
                strongSelf.initializeNavigationStack(viewController, user: $0, tier: tier)
                strongSelf.restoreToMostRecentPageIfNeeded(tier: tier)
            }, onError: { error in
                Logger.shared.error("Failed to get user: \(error.localizedDescription)")
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
            })
         disposables.insertWithDiscardableResult(disposable)
    }

    @objc func finish() {
        if navController == nil { return }
        navController.dismiss(animated: true)
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
                    controller.navigationItem.hidesBackButton = (nextPage == .applicationComplete)
                    
                    /// Tracking KYC completion is contextual based on what tier
                    /// the user is applying to.
                    if nextPage == .applicationComplete {
                        switch strongSelf.pager.tier {
                        case .tier0:
                            break
                        case .tier1:
                            AnalyticsService.shared.trackEvent(title: "kyc_tier1_complete")
                        case .tier2:
                            AnalyticsService.shared.trackEvent(title: "kyc_tier2_complete")
                        }
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
                    if strongSelf.appSettings.didRegisterForAirdropCampaignSucceed && strongSelf.pager.tier == .tier2 {
                        strongSelf.presentAccountStatusView(
                            for: .pending,
                            in: strongSelf.navController
                        )
                        return
                    }
                    strongSelf.finish()
                })
            disposables.insertWithDiscardableResult(disposable)
        }
    }

    func presentAccountStatusView(
        for status: KYCAccountStatus,
        in viewController: UIViewController
    ) {
        let accountStatusViewController = KYCInformationController.make(with: self)
        let isReceivingAirdrop = appSettings.didRegisterForAirdropCampaignSucceed
        accountStatusViewController.viewModel = KYCInformationViewModel.create(
            for: status,
            isReceivingAirdrop: isReceivingAirdrop
        )
        accountStatusViewController.viewConfig = KYCInformationViewConfig.create(
            for: status,
            isReceivingAirdrop: isReceivingAirdrop
        )
        accountStatusViewController.primaryButtonAction = { viewController in
            switch status {
            case .approved:
                viewController.dismiss(animated: true) {
                    guard let viewController = self.rootViewController else {
                        Logger.shared.error("View controller to present on is nil.")
                        return
                    }
                    ExchangeCoordinator.shared.start(rootViewController: viewController)
                }
            case .pending:
                PushNotificationManager.shared.requestAuthorization()
            case .failed, .expired:
                URL(string: Constants.Url.blockchainSupport)?.launch()
            case .none, .underReview: return
            }
        }
        presentInNavigationController(accountStatusViewController, in: viewController)
    }

    // MARK: View Restoration

    /// Restores the user to the most recent page if they dropped off mid-flow while KYC'ing
    private func restoreToMostRecentPageIfNeeded(tier: KYCTier) {
        guard let currentUser = user else {
            return
        }
        let latestPage = kycSettings.latestKycPage

        let startingPage = KYCPageType.startingPage(forUser: currentUser, tier: tier)

        guard let endPageForLastUsedTier = KYCPageType.pageType(for: currentUser, latestPage: latestPage) else {
            return
        }

        // If a user has moved to a new tier, they need to use the starting page for the new tier
        let endPage = endPageForLastUsedTier.rawValue >= startingPage.rawValue ? endPageForLastUsedTier : startingPage

        var currentPage = startingPage
        while currentPage != endPage {
            guard let nextPage = currentPage.nextPage(forTier: tier, user: user, country: country) else { return }

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
        case .enterEmail,
             .welcome,
             .country,
             .states,
             .profile,
             .address,
             .tier1ForcedTier2,
             .enterPhone,
             .verifyIdentity,
             .accountStatus,
             .applicationComplete:
            return nil
        }
    }

    private func initializeNavigationStack(_ viewController: UIViewController, user: NabuUser, tier: KYCTier) {
        let startingPage = appSettings.didRegisterForAirdropCampaignSucceed ?
            KYCPageType.welcome :
            KYCPageType.startingPage(forUser: user, tier: tier)
        let startingViewController = pageFactory.createFrom(
            pageType: startingPage,
            in: self
        )
        startingViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "close"),
            style: .plain,
            target: self,
            action: #selector(finish)
        )
        navController = presentInNavigationController(startingViewController, in: viewController)
    }

    // MARK: Private Methods

    private func handlePayloadFromPageType(_ pageType: KYCPageType, _ payload: KYCPagePayload?) {
        guard let payload = payload else { return }
        switch payload {
        case .countrySelected(let country):
            self.country = country
        case .phoneNumberUpdated,
             .emailPendingVerification:
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
        kycSettings.latestKycPage = type

        // Optionally apply page model
        switch type {
        case .tier1ForcedTier2,
             .welcome,
             .confirmEmail,
             .country,
             .states,
             .accountStatus,
             .applicationComplete:
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
    static func pageType(for user: NabuUser, latestPage: KYCPageType? = nil) -> KYCPageType? {
        if let latestPage = latestPage {
            return latestPage
        }
        
        let tier = user.tiers?.selected ?? .tier1
        switch tier {
        case .tier0:
            return nil
        case .tier1:
            return tier1PageType(for: user)
        case .tier2:
            return tier1PageType(for: user) ?? tier2PageType(for: user)
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

    private static func tier2PageType(for user: NabuUser) -> KYCPageType? {
        guard let mobile = user.mobile else { return .enterPhone }

        guard mobile.verified else { return .confirmPhone }

        guard user.status != .none else { return .verifyIdentity }

        return nil
    }
}
