//
//  SettingsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxCocoa

/// This enum aggregates possible action types that can be done in the dashboard
enum SettingsScreenAction {
    case launchChangePassword
    case launchWebLogin
    case promptGuidCopy
    case launchKYC
    case launchPIT
    case showAboutScreen
    case showBackupScreen
    case showURL(URL)
    case none
}

final class SettingsScreenPresenter {
    
    // MARK: Private Static Properties
    
    private static let termsOfServiceURL = URL(string: Constants.Url.termsOfService)!
    private static let privacyURL = URL(string: Constants.Url.privacyPolicy)!
    
    // MARK: - Types
    
    enum Section: Hashable {
        case profile
        case preferences
        case connect
        case security
        case about
        
        enum CellType: Hashable {
            case badge(BadgeCellType)
            case `switch`(SwitchCellType)
            case clipboard(ClipboardCellType)
            case plain(PlainCellType)
            
            enum BadgeCellType {
                case limits
                case emailVerification
                case mobileVerification
                case currencyPreference
                case pitConnection
                case twoStepVerification
                case recoveryPhrase
            }
            
            enum SwitchCellType {
                case emailNotifications
                case bioAuthentication
                case swipeToReceive
            }
            
            enum ClipboardCellType {
                case walletID
            }
            
            enum PlainCellType {
                case loginToWebWallet
                case changePassword
                case changePIN
                case about
                case termsOfService
                case privacyPolicy
                case cookiesPolicy
            }
        }
    }
    
    // MARK: - Public Properties
    
    var sectionArrangement: [Section] {
        var sections: [Section] = [.profile,
                                   .preferences,
                                   .security,
                                   .about]
        if interactor.pitLinkingConfiguration.isEnabled {
            sections.insert(.connect, at: 2)
        }
        
        return sections
    }
    
    var sectionCount: Int {
        return sectionArrangement.count
    }
    
    // MARK: - Cell Presenters
    
    let mobileCellPresenter: MobileVerificationCellPresenter
    let twoFactorCellPresenter: TwoFactorVerificationCellPresenter
    let emailCellPresenter: EmailVerificationCellPresenter
    let preferredCurrencyCellPresenter: PreferredCurrencyCellPresenter
    let emailNotificationsCellPresenter: EmailNotificationsSwitchCellPresenter
    let bioAuthenticationCellPresenter: BioAuthenticationSwitchCellPresenter
    let swipeReceiveCellPresenter: SwipeReceiveSwitchCellPresenter

    let pitCellPresenter: PITConnectionCellPresenter
    let recoveryCellPresenter: RecoveryStatusCellPresenter
    let limitsCellPresenter: TierLimitsCellPresenter

    // MARK: Private Properties
    
    private let interactor: SettingsScreenInteractor
    private let actionRelay = PublishRelay<SettingsScreenAction>()
    
    init(interactor: SettingsScreenInteractor = SettingsScreenInteractor()) {
        self.interactor = interactor
        
        emailNotificationsCellPresenter = EmailNotificationsSwitchCellPresenter(service: interactor.emailNotificationsService)
        emailCellPresenter = EmailVerificationCellPresenter(
            interactor: interactor.emailVerificationBadgeInteractor
        )
        mobileCellPresenter = MobileVerificationCellPresenter(
            interactor: interactor.mobileVerificationBadgeInteractor
        )
        twoFactorCellPresenter = TwoFactorVerificationCellPresenter(
            interactor: interactor.twoFactorVerificationBadgeInteractor
        )
        preferredCurrencyCellPresenter = PreferredCurrencyCellPresenter(
            interactor: interactor.preferredCurrencyBadgeInteractor
        )
        
        /// TODO: Provide interactor to the presenter as services
        /// should not be accessed from the presenter
        
        limitsCellPresenter = TierLimitsCellPresenter(
            tiersProviding: interactor.tiersProviding
        )
        pitCellPresenter = PITConnectionCellPresenter(
            pitConnectionProvider: interactor.pitConnnectionProviding
        )
        recoveryCellPresenter = RecoveryStatusCellPresenter(
            recoveryStatusProviding: interactor.recoveryPhraseStatusProviding
        )
        bioAuthenticationCellPresenter = BioAuthenticationSwitchCellPresenter(
            biometryProviding: interactor.biometryProviding,
            appSettingsAuthenticating: interactor.settingsAuthenticating
        )
        swipeReceiveCellPresenter = SwipeReceiveSwitchCellPresenter(
            appSettings: interactor.appSettings
        )
    }
    
    /// Should be called each time the `Settings` screen comes into view
    func refresh() {
        interactor.refresh()
    }
    
    // MARK: Private Functions
    
    func action(from cellType: Section.CellType) -> SettingsScreenAction {
        return cellType.action
    }
}

extension SettingsScreenPresenter.Section.CellType {
    var action: SettingsScreenAction {
        switch self {
        case .badge(let type):
            switch type {
            case .currencyPreference:
                break
            case .limits:
                return .launchKYC
            case .emailVerification:
                break
            case .mobileVerification:
                break
            case .pitConnection:
                return .launchPIT
            case .twoStepVerification:
                break
            case .recoveryPhrase:
                return .showBackupScreen
            }
        case .switch:
            break
        case .clipboard(let type):
            switch type {
            case .walletID:
                return .promptGuidCopy
            }
        case .plain(let type):
            switch type {
            case .about:
                return .showAboutScreen
            case .loginToWebWallet:
                return .launchWebLogin
            case .changePassword:
                return .launchChangePassword
            case .changePIN:
                break
            case .termsOfService:
                return .showURL(SettingsScreenPresenter.termsOfServiceURL)
            case .privacyPolicy,
                 .cookiesPolicy:
                return .showURL(SettingsScreenPresenter.privacyURL)
            }
        }
        return .none
    }
}

extension SettingsScreenPresenter.Section {
    var cellArrangement: [CellType] {
        switch self {
        case .profile:
            return [.badge(.limits),
                    .clipboard(.walletID),
                    .badge(.emailVerification),
                    .badge(.mobileVerification),
                    .plain(.loginToWebWallet)]
        case .preferences:
            return [.switch(.emailNotifications),
                    .badge(.currencyPreference)]
        case .connect:
            return [.badge(.pitConnection)]
        case .security:
            var arrangement: [CellType] = [.badge(.twoStepVerification),
                                           .plain(.changePassword),
                                           .badge(.recoveryPhrase),
                                           .plain(.changePIN),
                                           .switch(.bioAuthentication)]
            
            if AppFeatureConfigurator.shared.configuration(for: .swipeToReceive).isEnabled {
                arrangement.append(.switch(.swipeToReceive))
            }
            
            return arrangement
        case .about:
            return [.plain(.about),
                    .plain(.termsOfService),
                    .plain(.privacyPolicy),
                    .plain(.cookiesPolicy)]
        }
    }
    
    var sectionCellCount: Int {
        return cellArrangement.count
    }
    
    var sectionTitle: String {
        switch self {
        case .profile:
            return LocalizationConstants.Settings.Section.profile
        case .preferences:
            return LocalizationConstants.Settings.Section.preferences
        case .connect:
            return LocalizationConstants.Settings.Section.walletConnect
        case .security:
            return LocalizationConstants.Settings.Section.security
        case .about:
            return LocalizationConstants.Settings.Section.about
        }
    }
}

extension SettingsScreenPresenter.Section.CellType.ClipboardCellType {
    var title: String {
        switch self {
        case .walletID:
            return LocalizationConstants.Settings.walletID
        }
    }
}

extension SettingsScreenPresenter.Section.CellType.PlainCellType {
    var title: String {
        switch self {
        case .about:
            return LocalizationConstants.Settings.aboutUs
        case .loginToWebWallet:
            return LocalizationConstants.Settings.loginToWebWallet
        case .changePassword:
            return LocalizationConstants.Settings.changePassword
        case .changePIN:
            return LocalizationConstants.Settings.changePIN
        case .termsOfService:
            return LocalizationConstants.Settings.termsOfService
        case .privacyPolicy:
            return LocalizationConstants.Settings.privacyPolicy
        case .cookiesPolicy:
            return LocalizationConstants.Settings.cookiesPolicy
        }
    }
}

