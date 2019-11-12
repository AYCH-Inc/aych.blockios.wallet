//
//  WelcomeScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 10/4/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

final class WelcomeScreenPresenter {
    
    // MARK: - Types
    
    /// Abbreviation for localized strings
    private typealias LocalizedString = LocalizationConstants.Onboarding.WelcomeScreen
    private typealias AccessibilityId = Accessibility.Identifier.WelcomeScreen

    // MARK: - Properties
    
    let navBarStyle = Screen.Style.Bar.darkContent(
        ignoresStatusBar: false,
        background: .white
    )
    let title = LabelContent(
        text: LocalizedString.title,
        font: .mainSemibold(Constants.Booleans.isUsingScreenSizeEqualIphone5S ? 20 : 24),
        color: .titleText
    )
    let description: NSAttributedString = {
        let font = UIFont.mainMedium(Constants.Booleans.isUsingScreenSizeEqualIphone5S ? 14 : 16)
        let prefix = NSAttributedString(LocalizedString.Description.prefix, font: font, color: .mutedText)
        let send = NSAttributedString(LocalizedString.Description.send, font: font, color: .descriptionText)
        let receive = NSAttributedString(LocalizedString.Description.receive, font: font, color: .descriptionText)
        let store = NSAttributedString(LocalizedString.Description.store, font: font, color: .descriptionText)
        let trade = NSAttributedString(LocalizedString.Description.trade, font: font, color: .descriptionText)
        let comma = NSAttributedString(LocalizedString.Description.comma, font: font, color: .mutedText)
        let and = NSAttributedString(LocalizedString.Description.and, font: font, color: .mutedText)
        let suffix = NSAttributedString(LocalizedString.Description.suffix, font: font, color: .mutedText)
        return prefix + send + comma + receive + comma + store + and + trade + suffix
    }()
    let version = LabelContent(
        text: Bundle.applicationVersion ?? "",
        font: .mainMedium(12),
        color: .mutedText
    )
    
    private(set) var createWalletButtonViewModel: ButtonViewModel
    private(set) var loginButtonViewModel: ButtonViewModel
    private(set) var recoverFundsButtonViewModel: ButtonViewModel
    
    let createTapRelay = PublishRelay<Void>()
    let recoverFundsTapRelay = PublishRelay<Void>()
    let loginTapRelay = PublishRelay<Void>()
    
    // MARK: Injected
    
    let devSupport: DevSupporting
    private let launchAnnouncementPresenter: LaunchAnnouncementPresenter
    private let alertPresenter: AlertViewPresenter
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(alertPresenter: AlertViewPresenter = .shared,
         launchAnnouncementPresenter: LaunchAnnouncementPresenter = LaunchAnnouncementPresenter(),
         devSupport: DevSupporting = AppCoordinator.shared) {
        self.launchAnnouncementPresenter = launchAnnouncementPresenter
        self.alertPresenter = alertPresenter
        self.devSupport = devSupport
        
        let font = UIFont.mainSemibold(16)
        let cornerRadius: CGFloat = 8
        
        // Set create wallet button
        
        createWalletButtonViewModel = ButtonViewModel(
            font: font,
            cornerRadius: cornerRadius,
            accessibility: .id(AccessibilityId.Button.createWallet)
        )
        createWalletButtonViewModel.theme = .init(
            backgroundColor: .primaryButton,
            contentColor: .white,
            text: LocalizedString.Button.createWallet
        )
        createWalletButtonViewModel.tapRelay
            .bind(to: createTapRelay)
            .disposed(by: disposeBag)
        
        // Set login button
        
        loginButtonViewModel = ButtonViewModel(
            font: font,
            cornerRadius: cornerRadius,
            accessibility: .id(AccessibilityId.Button.login)
        )
        loginButtonViewModel.theme = .init(
            backgroundColor: .tertiaryButton,
            contentColor: .white,
            text: LocalizedString.Button.login
        )
        loginButtonViewModel.tapRelay
            .bind(to: loginTapRelay)
            .disposed(by: disposeBag)
        
        // Set recover funds button
        
        recoverFundsButtonViewModel = ButtonViewModel(
            font: font,
            cornerRadius: cornerRadius,
            accessibility: .init(id: .value(AccessibilityId.Button.recoverFunds))
        )
        recoverFundsButtonViewModel.theme = .init(
            backgroundColor: .white,
            borderColor: .mediumBorder,
            contentColor: .primaryButton,
            text: LocalizedString.Button.recoverFunds
        )
        recoverFundsButtonViewModel.tapRelay
            .bind(to: recoverFundsTapRelay)
            .disposed(by: disposeBag)
    }
    
    /// Should get called when the view appears
    func viewWillAppear() {
        launchAnnouncementPresenter.execute()
    }
}
