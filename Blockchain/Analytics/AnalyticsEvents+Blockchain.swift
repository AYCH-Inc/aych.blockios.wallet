//
//  AnalyticsEvents+Blockchain.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Analytics events classified by flow as described in the following Google Sheet:
/// https://docs.google.com/spreadsheets/d/1oJCRld_KrabJ9WyDKgMEnYYn5w79qUEhfOxnB6XQs9Q/edit?ts=5d6fb6a6#gid=0
/// To add an event please follow the the steps:
/// 1. Add the event under the relevant flow. If the flow does not exist, create a new one.
/// 2. Verify the validation test passes
/// 3. Add parameters if needed
/// 4. Copy the geenrated scripts here
/// 5. Implement the event using `AnalyticsEventRecording`
extension AnalyticsEvents {
    
    private struct Parameter {
        static let asset = "asset"
        static let currency = "currency"
    }
    
    // MARK: - Login / Signup
    
    enum Onboarding: AnalyticsEvent {
        case walletCreation
        case walletCreationError(error: String)
        case walletManualLogin
        case walletAutoPairingError
        case walletAutoPairing
        
        var name: String {
            switch self {
            // User creates Wallet
            case .walletCreation:
                return "wallet_creation"
            // Error is received while creating a wallet
            case .walletCreationError:
                return "wallet_creation_error"
            // User logs in manually to the Wallet
            case .walletManualLogin:
                return "wallet_manual_login"
            // User receives an error during scan (auto pairing)
            case .walletAutoPairingError:
                return "wallet_auto_pairing_error"
            // User logs in automatically to the Wallet
            case .walletAutoPairing:
                return "wallet_auto_pairing"
            }
        }
    }
    
    // MARK: - SideMenu
    
    enum SideMenu: AnalyticsEvent {
        case sideNavAccountsAndAddresses
        case sideNavBackup
        case sideNavBuyBitcoin
        case sideNavLogout
        case sideNavSettings
        case sideNavSupport
        case sideNavUpgrade
        case sideNavWebLogin
        case sideNavLockbox
        case sideNavPit
        
        var name: String {
            switch self {
            // Menu - accounts and addresses clicked
            case .sideNavAccountsAndAddresses:
                return "side_nav_accounts_and_addresses"
            // Menu - backup clicked
            case .sideNavBackup:
                return "side_nav_backup"
            // Menu - buy bitcoin clicked
            case .sideNavBuyBitcoin:
                return "side_nav_buy_bitcoin"
            // Menu - logout clicked
            case .sideNavLogout:
                return "side_nav_logout"
            // Menu - settings clicked
            case .sideNavSettings:
                return "side_nav_settings"
            // Menu - support clicked
            case .sideNavSupport:
                return "side_nav_support"
            // Menu - upgrade clicked
            case .sideNavUpgrade:
                return "side_nav_upgrade"
            // Menu - web login clicked
            case .sideNavWebLogin:
                return "side_nav_web_login"
            // Menu - lockbox clicked
            case .sideNavLockbox:
                return "side_nav_lockbox"
            // Menu - pit clicked
            case .sideNavPit:
                return "side_nav_pit"
            }
        }
    }
    
    // MARK: - Announcement
    
    enum Announcement: AnalyticsEvent {
        case cardShown(type: AnnouncementType)
        case cardActioned(type: AnnouncementType)
        case cardDismissed(type: AnnouncementType)
        
        var name: String {
            switch self {
            // User is shown a particular onboarding card
            case .cardShown:
                return "card_shown"
            // User interacts with a given card
            case .cardActioned:
                return "card_actioned"
            // User dismisses a given card
            case .cardDismissed:
                return "card_dismissed"
            }
        }
        
        var params: [String : String]? {
            return ["card_title": type.rawValue]
        }
        
        private var type: AnnouncementType {
            switch self {
            case .cardShown(type: let type):
                return type
            case .cardActioned(type: let type):
                return type
            case .cardDismissed(type: let type):
                return type
            }
        }
    }
    
    // MARK: - Wallet Intro Flow
    
    enum WalletIntro: AnalyticsEvent {
        case walletIntroOffered
        case walletIntroPortfolioViewed
        case walletIntroSendViewed
        case walletIntroRequestViewed
        case walletIntroSwapViewed
        case walletIntroBuysellViewed
        
        var name: String {
            switch self {
            // Intro - User shown card to begin Wallet Intro
            case .walletIntroOffered:
                return "wallet_intro_offered"
            // Intro - User views "View your portfolio" card
            case .walletIntroPortfolioViewed:
                return "wallet_intro_portfolio_viewed"
            // Intro - User views "Send" card
            case .walletIntroSendViewed:
                return "wallet_intro_send_viewed"
            // Intro - User views "Request" card
            case .walletIntroRequestViewed:
                return "wallet_intro_request_viewed"
            // Intro - User views "Swap" card
            case .walletIntroSwapViewed:
                return "wallet_intro_swap_viewed"
            // Intro - User views "Buy and Sell" card
            case .walletIntroBuysellViewed:
                return "wallet_intro_buysell_viewed"
            }
        }
        
        var params: [String : String]? {
            return nil
        }
    }
    
    // MARK: - Bitpay

    enum Bitpay: AnalyticsEvent {
        case bitpayPaymentSuccess
        case bitpayPaymentFailure(error: Error?)
        case bitpayPaymentExpired
        case bitpayUrlScanned(asset: AssetType)
        case bitpayUrlPasted(asset: AssetType)
        case bitpayUrlDeeplink(asset: AssetType)

        var name: String {
            switch self {
            // User successfully pays a Bitpay payment request
            case .bitpayPaymentSuccess:
                return "bitpay_payment_success"
            // User fails to pay a Bitpay payment request
            case .bitpayPaymentFailure:
                return "bitpay_payment_failure"
            // User's payment request expired
            case .bitpayPaymentExpired:
                return "bitpay_payment_expired"
            // User scans a Bitpay QR code
            case .bitpayUrlScanned:
                return "bitpay_url_scanned"
            // User pastes a bitpay URL in the address field
            case .bitpayUrlPasted:
                return "bitpay_url_pasted"
            // User deep links into the app after tapping a Bitpay URL
            case .bitpayUrlDeeplink:
                return "bitpay_url_deeplink"
            }
        }

        var params: [String : String]? {
            switch self {
            case .bitpayUrlDeeplink(asset: let asset),
                 .bitpayUrlScanned(asset: let asset),
                 .bitpayUrlPasted(asset: let asset):
                return ["currency": asset.cryptoCurrency.rawValue]
            case .bitpayPaymentExpired,
                 .bitpayPaymentSuccess:
                return nil
            case .bitpayPaymentFailure(error: let error):
                guard let error = error else { return nil }
                return ["error": error.localizedDescription]
            }
        }
    }
    
    // MARK: - Send flow
    
    enum Send: AnalyticsEvent {
        case sendTabItemClick
        case sendFormConfirmClick(asset: AssetType)
        case sendFormConfirmSuccess(asset: AssetType)
        case sendFormConfirmFailure(asset: AssetType)
        case sendFormShowErrorAlert(asset: AssetType)
        case sendFormErrorAppear(asset: AssetType)
        case sendFormErrorClick(asset: AssetType)
        case sendFormUseBalanceClick(asset: AssetType)
        case sendFormPitButtonClick(asset: AssetType)
        case sendFormQrButtonClick(asset: AssetType)
        case sendSummaryConfirmClick(asset: AssetType)
        case sendSummaryConfirmSuccess(asset: AssetType)
        case sendSummaryConfirmFailure(asset: AssetType)
        case sendBitpayPaymentFailure(asset: AssetType)
        case sendBitpayPaymentSuccess(asset: AssetType)
        
        var name: String {
            switch self {
            // Send - tab item click
            case .sendTabItemClick:
                return "send_tab_item_click"
            // Send - form send click
            case .sendFormConfirmClick:
                return "send_form_confirm_click"
            // Send - form send success
            case .sendFormConfirmSuccess:
                return "send_form_confirm_success"
            // Send - form send failure
            case .sendFormConfirmFailure:
                return "send_form_confirm_failure"
            // Send - form show error alert
            case .sendFormShowErrorAlert:
                return "send_form_show_error_alert"
            // Send - form send error appears (⚠️)
            case .sendFormErrorAppear:
                return "send_form_error_appear"
            // Send - form send error click (⚠️)
            case .sendFormErrorClick:
                return "send_form_error_click"
            // Send - use spendable balance click
            case .sendFormUseBalanceClick:
                return "send_form_use_balance_click"
            // Send - PIT button click
            case .sendFormPitButtonClick:
                return "send_form_pit_button_click"
            // Send - QR button click
            case .sendFormQrButtonClick:
                return "send_form_qr_button_click"
            // Send - summary send click
            case .sendSummaryConfirmClick:
                return "send_summary_confirm_click"
            // Send - summary send success
            case .sendSummaryConfirmSuccess:
                return "send_summary_confirm_success"
            // Send - summary send failure
            case .sendSummaryConfirmFailure:
                return "send_summary_confirm_failure"
            // Send - bitpay send failure
            case .sendBitpayPaymentFailure:
                return "send_bitpay_payment_failure"
            // Send - bitpay send success
            case .sendBitpayPaymentSuccess:
                return "send_bitpay_payment_success"
            }
        }
        
        var params: [String : String]? {
            let assetParamName = Parameter.asset
            switch self {
            case .sendTabItemClick:
                return nil
            case .sendFormConfirmClick(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormConfirmSuccess(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormConfirmFailure(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormErrorAppear(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormErrorClick(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormUseBalanceClick(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormShowErrorAlert(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormPitButtonClick(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendFormQrButtonClick(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendSummaryConfirmClick(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendSummaryConfirmSuccess(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendSummaryConfirmFailure(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendBitpayPaymentFailure(asset: let asset):
                return [assetParamName: asset.symbol]
            case .sendBitpayPaymentSuccess(asset: let asset):
                return [assetParamName: asset.symbol]
            }
        }
    }
    
    // MARK: - Swap flow
    
    enum Swap: AnalyticsEvent {
        case swapTabItemClick
        case swapIntroStartButtonClick
        case swapFormConfirmClick
        case swapFormConfirmSuccess
        case swapFormConfirmError(message: String)
        case swapFormConfirmErrorAppear
        case swapFormConfirmErrorClick(error: ExchangeError)
        case swapSummaryConfirmClick
        case swapSummaryConfirmFailure
        case swapSummaryConfirmSuccess
        case swapReversePairClick
        case swapLeftAssetClick
        case swapRightAssetClick
        case swapExchangeChangeReceived
        case swapInputValueChanged(crypto: String, fiat: String, fiatAmount: String)
        case swapViewHistoryButtonClick
        case swapHistoryOrderClick
        case swapHistoryOrderIdCopied
        
        var name: String {
            switch self {
            // Swap - tab item click
            case .swapTabItemClick:
                return "swap_tab_item_click"
            // Swap - intro start button clicked
            case .swapIntroStartButtonClick:
                return "swap_intro_start_button_click"
            // Swap - confirm amount click
            case .swapFormConfirmClick:
                return "swap_form_confirm_click"
            // Swap - confirm amount success
            case .swapFormConfirmSuccess:
                return "swap_form_confirm_success"
            // Swap - confirm amount error
            case .swapFormConfirmError:
                return "swap_form_confirm_error"
            // Swap - error appears (⚠️)
            case .swapFormConfirmErrorAppear:
                return "swap_form_confirm_error_appear"
            // Swap - error click (⚠️)
            case .swapFormConfirmErrorClick:
                return "swap_form_confirm_error_click"
            // Swap - summary final confirmation click confirm
            case .swapSummaryConfirmClick:
                return "swap_summary_confirm_click"
            // Swap - summary final confirmation failure
            case .swapSummaryConfirmFailure:
                return "swap_summary_confirm_failure"
            // Swap - summary final confirmation success
            case .swapSummaryConfirmSuccess:
                return "swap_summary_confirm_success"
            // Swap - reverse pair button clicked
            case .swapReversePairClick:
                return "swap_reverse_pair_click"
            // Swap - left asset button clicked
            case .swapLeftAssetClick:
                return "swap_left_asset_click"
            // Swap - right asset button clicked
            case .swapRightAssetClick:
                return "swap_right_asset_click"
            // Swap - exchange receive change
            case .swapExchangeChangeReceived:
                return "swap_exchange_change_received"
            // Swap - input swap value
            case .swapInputValueChanged:
                return "swap_input_value_changed"
            // Swap - history button clicked
            case .swapViewHistoryButtonClick:
                return "swap_view_history_button_click"
            // Swap - history specific order clicked
            case .swapHistoryOrderClick:
                return "swap_history_order_click"
            // Swap - history order id coptied
            case .swapHistoryOrderIdCopied:
                return "swap_history_order_id_copied"
            }
        }
        
        var params: [String : String]? {
            switch self {
            case .swapFormConfirmError(message: let message):
                return ["message": message]
            default:
                return nil
            }
        }
    }
        
    // MARK: - Transactions flow
    
    enum Transactions: AnalyticsEvent {
        case transactionsTabItemClick
        case transactionsListItemClick(asset: AssetType)
        case transactionsItemShareClick(asset: AssetType)
        case transactionsItemWebViewClick(asset: AssetType)
        
        var name: String {
            switch self {
            // Transactions - tab item click
            case .transactionsTabItemClick:
                return "transactions_tab_item_click"
            // Transactions - transaction item clicked
            case .transactionsListItemClick:
                return "transactions_list_item_click"
            // Transaction - share button clicked
            case .transactionsItemShareClick:
                return "transactions_item_share_click"
            // Transaction - view on web clicked
            case .transactionsItemWebViewClick:
                return "transactions_item_web_view_click"
            }
        }
        
        var params: [String : String]? {
            switch self {
            // Transactions - transaction item clicked
            case .transactionsListItemClick(asset: let asset):
                return [Parameter.asset: asset.symbol]
            // Transaction - share button clicked
            case .transactionsItemShareClick(asset: let asset):
                return [Parameter.asset: asset.symbol]
            // Transaction - view on web clicked
            case .transactionsItemWebViewClick(asset: let asset):
                return [Parameter.asset: asset.symbol]
            default:
                return nil
            }
        }
    }
    
    // MARK: - KYC flow
    
    enum KYC: AnalyticsEvent {
        case kycVerifyEmailButtonClick
        case kycCountrySelected
        case kycPersonalDetailSet(fieldName: String)
        case kycAddressDetailSet
        case kycVerifyIdStartButtonClick
        case kycVeriffInfoSubmitted
        case kycUnlockSilverClick
        case kycUnlockGoldClick
        case kycPhoneUpdateButtonClick
        case kycEmailUpdateButtonClick
        
        var name: String {
            switch self {
            // KYC - send verification email button click
            case .kycVerifyEmailButtonClick:
                return "kyc_verify_email_button_click"
            // KYC - country selected
            case .kycCountrySelected:
                return "kyc_country_selected"
            // KYC - personal detail changed
            case .kycPersonalDetailSet:
                return "kyc_personal_detail_set"
            // KYC - address changed
            case .kycAddressDetailSet:
                return "kyc_address_detail_set"
            // KYC - verify identity start button click
            case .kycVerifyIdStartButtonClick:
                return "kyc_verify_id_start_button_click"
            // KYC - info veriff info submitted
            case .kycVeriffInfoSubmitted:
                return "kyc_veriff_info_submitted"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockSilverClick:
                return "kyc_unlock_silver_click"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockGoldClick:
                return "kyc_unlock_gold_click"
            // KYC - phone number update button click
            case .kycPhoneUpdateButtonClick:
                return "kyc_phone_update_button_click"
            // KYC - email update button click
            case .kycEmailUpdateButtonClick:
                return "kyc_email_update_button_click"
            }
        }
        
        var params: [String : String]? {
            return nil
        }
    }
    
    // MARK: - Settings flow
    
    enum Settings: AnalyticsEvent {
        case settingsEmailClicked
        case settingsPhoneClicked
        case settingsWebWalletLoginClick
        case settingsSwapLimitClicked
        case settingsSwipeToReceiveSwitch(value: Bool)
        case settingsWalletIdCopyClick
        case settingsWalletIdCopied
        case settingsEmailNotifSwitch(value: Bool)
        case settingsPasswordClick
        case settingsTwoFaClick
        case settingsRecoveryPhraseClick
        case settingsChangePinClick
        case settingsBiometryAuthSwitch(value: Bool)
        case settingsLanguageSelected(language: String)
        case settingsPinSelected
        case settingsPasswordSelected
        case settingsCurrencySelected(currency: String)
        
        var name: String {
            switch self {
            // Settings - email clicked
            case .settingsEmailClicked:
                return "settings_email_clicked"
            // Settings - phone clicked
            case .settingsPhoneClicked:
                return "settings_phone_clicked"
            // Settings - login to web wallet clicked
            case .settingsWebWalletLoginClick:
                return "settings_web_wallet_login_click"
            // Settings - swap limit clicked
            case .settingsSwapLimitClicked:
                return "settings_swap_limit_clicked"
            // Settings - swipe to receive switch clicked
            case .settingsSwipeToReceiveSwitch:
                return "settings_swipe_to_receive_switch"
            // Settings - wallet id copy clicked
            case .settingsWalletIdCopyClick:
                return "settings_wallet_id_copy_click"
            // Settings - wallet id copied
            case .settingsWalletIdCopied:
                return "settings_wallet_id_copied"
            // Settings - email notifications switch clicked
            case .settingsEmailNotifSwitch:
                return "settings_email_notif_switch"
            // Settings - change password clicked
            case .settingsPasswordClick:
                return "settings_password_click"
            // Settings - two factor auth clicked
            case .settingsTwoFaClick:
                return "settings_two_fa_click"
            // Settings - recovery phrase clicked
            case .settingsRecoveryPhraseClick:
                return "settings_recovery_phrase_click"
            // Settings - change PIN clicked
            case .settingsChangePinClick:
                return "settings_change_pin_click"
            // Settings - biometry auth switch
            case .settingsBiometryAuthSwitch:
                return "settings_biometry_auth_switch"
            // Settings - change language
            case .settingsLanguageSelected:
                return "settings_language_selected"
            // Settings - PIN changed
            case .settingsPinSelected:
                return "settings_pin_selected"
            // Settings - change password
            case .settingsPasswordSelected:
                return "settings_password_selected"
            // Settings - change currency
            case .settingsCurrencySelected:
                return "settings_currency_selected"
            }
        }
        
        var params: [String : String]? {
            return nil
        }
    }
    
    enum Permission: AnalyticsEvent {
        case permissionPreCameraApprove
        case permissionPreCameraDecline
        case permissionSysCameraApprove
        case permissionSysCameraDecline
        case permissionPreMicApprove
        case permissionPreMicDecline
        case permissionSysMicApprove
        case permissionSysMicDecline
        case permissionSysNotifRequest
        case permissionSysNotifApprove
        case permissionSysNotifDecline
        
        var name: String {
            switch self {
            // Permission - camera preliminary approve
            case .permissionPreCameraApprove:
                return "permission_pre_camera_approve"
            // Permission - camera preliminary decline
            case .permissionPreCameraDecline:
                return "permission_pre_camera_decline"
            // Permission - camera system approve
            case .permissionSysCameraApprove:
                return "permission_sys_camera_approve"
            // Permission - camera system decline
            case .permissionSysCameraDecline:
                return "permission_sys_camera_decline"
            // Permission - mic preliminary approve
            case .permissionPreMicApprove:
                return "permission_pre_mic_approve"
            // Permission - mic preliminary decline
            case .permissionPreMicDecline:
                return "permission_pre_mic_decline"
            // Permission - mic system approve
            case .permissionSysMicApprove:
                return "permission_sys_mic_approve"
            // Permission - mic system decline
            case .permissionSysMicDecline:
                return "permission_sys_mic_decline"
            // Permission - remote notification system request
            case .permissionSysNotifRequest:
                return "permission_sys_notif_request"
            // Permission - remote notification system approve
            case .permissionSysNotifApprove:
                return "permission_sys_notif_approve"
            // Permission - remote notification system decline
            case .permissionSysNotifDecline:
                return "permission_sys_notif_decline"
            }
        }
    }
    
    // MARK: - Asset Selector
    
    enum AssetSelection: AnalyticsEvent {
        case assetSelectorOpen(asset: AssetType)
        case assetSelectorClose(asset: AssetType)
        
        var name: String {
            switch self {
            // Asset Selector - asset selector opened
            case .assetSelectorOpen:
                return "asset_selector_open"
            // Asset Selector - asset selector closed
            case .assetSelectorClose:
                return "asset_selector_close"
            }
        }
        
        var params: [String : String]? {
            switch self {
            case .assetSelectorOpen(asset: let asset):
                return [Parameter.asset: asset.symbol]
            case .assetSelectorClose(asset: let asset):
                return [Parameter.asset: asset.symbol]
            }
        }
    }
}
