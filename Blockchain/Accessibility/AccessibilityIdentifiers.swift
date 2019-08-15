//
//  AccessibilityIdentifiers.swift
//  Blockchain
//
//  Created by Jack on 03/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AccessibilityIdentifiers: NSObject {
    @objc(AccessibilityIdentifiers_WelcomeScreen) class WelcomeScreen: NSObject {
        @objc static let createWalletButton = "WelcomeScreen.createWalletButton"
        @objc static let loginButton = "WelcomeScreen.loginButton"
        @objc static let recoverFundsButton = "WelcomeScreen.recoverFundsButton"
    }
    
    @objc(AccessibilityIdentifiers_CreateWalletScreen) class CreateWalletScreen: NSObject {
        @objc static let emailField = "CreateWalletScreen.emailField"
        @objc static let passwordField = "CreateWalletScreen.passwordField"
        @objc static let confirmPasswordField = "CreateWalletScreen.confirmPasswordField"
        @objc static let privacyPolicyTappableView = "CreateWalletScreen.privacyPolicyTappableView"
        @objc static let termsOfServiceTappableView = "CreateWalletScreen.termsOfServiceTappableView"
        @objc static let createWalletButton = "CreateWalletScreen.createWalletButton"
    }
    
    struct PinScreen {
        static let prefix = "PinScreen."
    
        static let pinSecureViewTitle = "\(prefix)titleLabel"
        static let pinIndicatorFormat = "\(prefix)pinIndicator-"
        
        static let digitButtonFormat = "\(prefix)digit-"
        static let faceIdButton = "\(prefix)faceIdButton"
        static let touchIdButton = "\(prefix)touchIdButton"
        static let backspaceButton = "\(prefix)backspaceButton"
        
        static let errorLabel = "\(prefix)errorLabel"
        
        static let versionLabel = "\(prefix)versionLabel"
        static let swipeLabel = "\(prefix)swipeLabel"
    }
    
    struct Address {
        static let prefix = "AddressScreen."
        
        static let assetNameLabel = "\(prefix)assetNameLabel"
        static let assetImageView = "\(prefix)assetImageView"
        
        static let addressLabel = "\(prefix)addressLabel"
        static let qrImageView = "\(prefix)addressQRImage"
        static let copyButton = "\(prefix)copyButton"
        static let shareButton = "\(prefix)shareButton"
        static let pageControl = "\(prefix)pageControl"
    }
    
    @objc(AccessibilityIdentifiers_WalletSetupScreen) class WalletSetupScreen: NSObject {
        @objc static let biometricTitleLabel = "WalletSetupScreen.biometricTitleLabel"
        @objc static let biometricBodyTextView = "WalletSetupScreen.biometricBodyTextView"
        @objc static let biometricEnableButton = "WalletSetupScreen.biometricEnableButton"
        @objc static let biometricDoneButton = "WalletSetupScreen.biometricDoneButton"
        
        @objc static let emailTitleLabel = "WalletSetupScreen.emailTitleLabel"
        @objc static let emailEmailLabel = "WalletSetupScreen.emailEmailLabel"
        @objc static let emailBodyTextView = "WalletSetupScreen.emailBodyTextView"
        @objc static let emailOpenMailButton = "WalletSetupScreen.emailOpenMailButton"
        @objc static let emailDoneButton = "WalletSetupScreen.emailDoneButton"
    }
    
    @objc(AccessibilityIdentifiers_WalletSetupReminderScreen) class WalletSetupReminderScreen: NSObject {
        @objc static let titleLabel = "WalletSetupReminderScreen.titleLabel"
        @objc static let emailLabel = "WalletSetupReminderScreen.emailLabel"
        @objc static let detailLabel = "WalletSetupReminderScreen.detailLabel"
        @objc static let continueButton = "WalletSetupReminderScreen.continueButton"
        @objc static let cancelButton = "WalletSetupReminderScreen.cancelButton"
    }

    class KYCVerifyIdentityScreen: NSObject {
        static let headerText = "KYCVerifyIdentityScreen.headerText"
        static let subheaderText = "KYCVerifyIdentityScreen.subheaderText"
        static let passportText = "KYCVerifyIdentityScreen.passportText"
        static let nationalIDCardText = "KYCVerifyIdentityScreen.nationalIDCardText"
        static let residenceCardText = "KYCVerifyIdentityScreen.residenceCardText"
        static let driversLicenseText = "KYCVerifyIdentityScreen.driversLicenseText"
        static let enableCameraHeaderText = "KYCVerifyIdentityScreen.enableCameraHeaderText"
        static let enableCameraSubheaderText = "KYCVerifyIdentityScreen.enableCameraSubheaderText"
        static let countrySupportedHeaderText = "KYCVerifyIdentityScreen.countrySupportedHeaderText"
        static let countrySupportedSubheaderText = "KYCVerifyIdentityScreen.countrySupportedSubheaderText"
    }

    @objc(AccessibilityIdentifiers_TransactionListItem) class TransactionListItem: NSObject {
        @objc static let date = "TransactionListItem.date"
        @objc static let amount = "TransactionListItem.amount"
        @objc static let info = "TransactionListItem.info"
        @objc static let action = "TransactionListItem.action"
        @objc static let warning = "TransactionListItem.warning"
    }
    
    @objc(AccessibilityIdentifiers_TabViewContainerScreen) class TabViewContainerScreen: NSObject {
        @objc static let activity = "TabViewContainerScreen.activity"
        @objc static let swap = "TabViewContainerScreen.swap"
        @objc static let home = "TabViewContainerScreen.home"
        @objc static let send = "TabViewContainerScreen.send"
        @objc static let request = "TabViewContainerScreen.request"
    }
    
    class SwapIntroduction {
        static let startNow = "SwapIntroductionScreen.StartNowButton"
    }
    
    // MARK: - Navigation
    
    @objc(AccessibilityIdentifiers_Navigation) class Navigation: NSObject {
        private static let prefix = "NavigationBar."
        @objc static let backButton = "\(prefix)backButton"
        @objc static let closeButton = "\(prefix)closeButton"
        @objc static let warningButton = "\(prefix)warningButton"
        @objc static let titleLabel = "\(prefix)titleLabel"
        
        class Button {
            private static let prefix = "\(Navigation.prefix)Button."
            
            static let qrCode = "\(prefix)qrCode"
            static let dismiss = "\(prefix)dismiss"
            static let menu = "\(prefix)menu"
            static let help = "\(prefix)help"
            static let back = "\(prefix)back"
            static let error = "\(prefix)error"
            static let activityIndicator = "\(prefix)activityIndicator"
        }
    }
    
    // MARK: - Asset Selection
    
    struct AssetSelection {
        private static let prefix = "AssetSelection."
        
        static let toggleButton = "\(prefix)toggleButton"
        static let assetPrefix = "\(prefix)"
    }
    
    // MARK: - Send
    
    struct SendScreen {
        private static let prefix = "SendScreen."
        
        static let sourceAccountTitleLabel = "\(prefix)sourceAccountTitleLabel"
        static let sourceAccountValueLabel = "\(prefix)sourceAccountValueLabel"
        
        static let destinationAddressTitleLabel = "\(prefix)destinationAddressTitleLabel"
        static let destinationAddressTextField = "\(prefix)destinationAddressTextField"
        static let destinationAddressIndicatorLabel = "\(prefix)destinationAddressIndicatorLabel"
        
        static let feesTitleLabel = "\(prefix)feesTitleLabel"
        static let feesValueLabel = "\(prefix)feesValueLabel"
        
        static let cryptoTitleLabel = "\(prefix)cryptoTitleLabel"
        static let cryptoAmountTextField = "\(prefix)cryptoAmountTextField"
        
        static let fiatTitleLabel = "\(prefix)fiatTitleLabel"
        static let fiatAmountTextField = "\(prefix)fiatAmountTextField"
        
        static let maxAvailableLabel = "\(prefix)maxAvailableLabel"

        static let pitAddressButton = "\(prefix)pitAddressButton"
        static let addressesButton = "\(prefix)addressesButton"
        
        static let errorLabel = "\(prefix)errorLabel"
        
        static let continueButton = "\(prefix)continueButton"
        
        struct Stellar {
            static let memoLabel = "\(prefix)memoLabel"
            static let memoSelectionTypeButton = "\(prefix)memoSelectionTypeButton"
            static let memoTextField = "\(prefix)memoTextField"
            static let memoIDTextField = "\(prefix)memoIDTextField"
            static let moreInfoButton = "\(prefix)moreInfoButton"
            static let sendingToExchangeLabel = "\(prefix)sendingToAnExchangeLabel"
            static let addAMemoLabel = "\(prefix)addAMemoLabel"
        }
    }
    
    // MARK: - Swap / Exchange
    
    struct Exchange {
        private static let prefix = "ExchangeScreen."
        
        // MARK: - Create
        
        struct Create {
            private static let prefix = "\(Exchange.prefix)CreateScreen."
            
            static let backButton = "\(prefix)backButton"
            static let dismissButton = "\(prefix)dismissButton"
            
            static let primaryAmountLabel = "\(prefix)primaryAmountLabel"
            static let secondaryAmountLabel = "\(prefix)secondaryAmountLabel"
            
            static let walletBalanceLabel = "\(prefix)walletBalanceLabel"
            static let conversionRateLabel = "\(prefix)conversionRateLabel"
        }
        
        // MARK: - Details
        
        struct Details {
            private static let prefix = "\(Exchange.prefix)DetailsScreen."
            
            static let fiatDescriptionLabel = "\(prefix)fiatDescriptionLabel"
            static let fiatValueLabel = "\(prefix)fiatValueLabel"
            
            static let cryptoDescriptionLabel = "\(prefix)cryptoDescriptionLabel"
            static let cryptoValueLabel = "\(prefix)cryptoValueLabel"
            
            static let feesDescriptionLabel = "\(prefix)feesDescriptionLabel"
            static let feesValueLabel = "\(prefix)feesValueLabel"
            
            static let receiveDescriptionLabel = "\(prefix)receiveDescriptionLabel"
            static let receiveValueLabel = "\(prefix)receiveValueLabel"
            
            static let destinationDescriptionLabel = "\(prefix)destinationDescriptionLabel"
            static let destinationValueLabel = "\(prefix)destinationValueLabel"
            
            static let statusDescriptionLabel = "\(prefix)statusDescriptionLabel"
            static let statusValueLabel = "\(prefix)statusValueLabel"
            
            static let orderIdDescriptionLabel = "\(prefix)orderIdDescriptionLabel"
            static let orderIdValueLabel = "\(prefix)orderIdValueLabel"
        }
        
        // MARK: - Trading Pair 
    
        struct TradingPair {
            static let exchangeLabel = "\(prefix)exchangeLabel"
            static let exchangeButton = "\(prefix)exchangeButton"
            static let receiveLabel = "\(prefix)receiveLabel"
            static let receiveButton = "\(prefix)receiveButton"
            static let swapButton = "\(prefix)swapButton"
        }
    }
    
    @objc(AccessibilityIdentifiers_ConfirmSend) class ConfirmSend: NSObject {
        private static let prefix = "ConfirmSend."
        
        @objc static let fiatAmountTitleLabel = "\(prefix)fiatAmountTitleLabel"
        @objc static let descriptionTextField = "\(prefix)descriptionTextField"
    }
    
    // MARK: - Amount (Fiat / Crypto)
    
    @objc(AccessibilityIdentifiers_AmountInput) class AmountInput: NSObject {
        private static let prefix = "AmountInput."
        
        @objc static let cryptoAmountTitleLabel = "\(prefix)cryptoAmountTitleLabel"
        @objc static let cryptoAmountTextField = "\(prefix)cryptoAmountTextField"
        
        @objc static let fiatAmountTitleLabel = "\(prefix)fiatAmountTitleLabel"
        @objc static let fiatAmountTextField = "\(prefix)fiatAmountTextField"
    }
    
    @objc(AccessibilityIdentifiers_TotalAmount) class TotalAmount: NSObject {
        private static let prefix = "TotalAmount."
        
        @objc static let fiatAmountLabel = "\(prefix)fiatAmountLabel"
        @objc static let cryptoAmountLabel = "\(prefix)cryptoAmountLabel"
    }
    
    // MARK: - General
    
    @objc(AccessibilityIdentifiers_General) class General: NSObject {
        private static let prefix = "General."
        @objc static let mainCTAButton = "\(prefix)mainCTAButton"
    }
    
    // MARK: - Number Keypad
    
    class NumberKeypadView {
        static let numberButton = "NumberKeypadView.numberButton"
        static let decimalButton = "NumberKeypadView.decimalButton"
        static let backspace = "NumberKeypadView.backspace"
    }
    
    // MARK: - Password Confirmation
    
    struct PasswordConfirm {
        private static let prefix = "PasswordConfirm."
        static let passwordTextField = "\(prefix)passwordTextField"
        static let descriptionLabel = "\(prefix)descriptionLabel"
    }
    
    // MARK: Dashboard
    
    class AnnouncementCard {
        static let dismissButton = "AnnouncementCard.dismissButton"
        static let actionButton = "AnnouncementCard.actionButton"
    }
}
