//
//  BadgeCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit
import RxCocoa

/// This is used on `BadgeTableViewCell`. There are many
/// types of `BadgeTableViewCell` (e.g. PIT connection status, KYC status, mobile
/// verification status, etc). Each of these cells need their own implementation of
/// `LabelContentPresenting` and `BadgeAssetPresenting`
protocol BadgeCellPresenting {
    var labelContentPresenting: LabelContentPresenting { get }
    var badgeAssetPresenting: BadgeAssetPresenting { get }
}

/// A `BadgeCellPresenting` class for showing the user's mobile verification status
final class MobileVerificationCellPresenter: BadgeCellPresenting {
    
    // MARK: - Properties
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    // MARK: - Setup
    
    init(interactor: MobileVerificationBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            title: LocalizationConstants.Settings.Badge.mobileNumber,
            descriptors: .settings
        )
        badgeAssetPresenting = MobileVerificationBadgePresenter(
            interactor: interactor
        )
    }
}

/// A `BadgeCellPresenting` class for showing the user's 2FA verification status
final class TwoFactorVerificationCellPresenter: BadgeCellPresenting {
    
    // MARK: - Properties
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    // MARK: - Setup
    
    init(interactor: TwoFactorVerificationBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            title: LocalizationConstants.Settings.Badge.twoFactorAuthentication,
            descriptors: .settings
        )
        badgeAssetPresenting = TwoFactorVerificationBadgePresenter(
            interactor: interactor
        )
    }
}

/// A `BadgeCellPresenting` class for showing the user's 2FA verification status
final class EmailVerificationCellPresenter: BadgeCellPresenting {
    
    // MARK: - Properties
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    init(interactor: EmailVerificationBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            title: LocalizationConstants.Settings.Badge.email,
            descriptors: .settings
        )
        badgeAssetPresenting = EmailVerificationBadgePresenter(
            interactor: interactor
        )
    }
}

/// A `BadgeCellPresenting` class for showing the user's preferred local currency
final class PreferredCurrencyCellPresenter: BadgeCellPresenting {
    
    // MARK: - Properties
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    // MARK: - Setup
    
    init(interactor: PreferredCurrencyBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            title: LocalizationConstants.Settings.Badge.localCurrency,
            descriptors: .settings
        )
        badgeAssetPresenting = PreferredCurrencyBadgePresenter(
            interactor: interactor
        )
    }
}

/// A `BadgeCellPresenting` class for showing the user's Swap Limits
final class TierLimitsCellPresenter: BadgeCellPresenting {
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    init(tiersProviding: TierLimitsProviding) {
        labelContentPresenting = TierLimitsLabelContentPresenter(provider: tiersProviding, descriptors: .settings)
        badgeAssetPresenting = TierLimitsBadgePresenter(provider: tiersProviding)
    }
}

/// A `BadgeCellPresenting` class for showing the user's PIT connection status
final class PITConnectionCellPresenter: BadgeCellPresenting {
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    init(pitConnectionProvider: PITConnectionStatusProviding) {
        labelContentPresenting = DefaultLabelContentPresenter(title: LocalizationConstants.Settings.Badge.blockchainExchange, descriptors: .settings)
        badgeAssetPresenting = PITConnectionBadgePresenter(provider: pitConnectionProvider)
    }
}

/// A `BadgeCellPresenting` class for showing the user's recovery phrase status
final class RecoveryStatusCellPresenter: BadgeCellPresenting {
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    init(recoveryStatusProviding: RecoveryPhraseStatusProviding) {
        labelContentPresenting = DefaultLabelContentPresenter(title: LocalizationConstants.Settings.Badge.recoveryPhrase, descriptors: .settings)
        badgeAssetPresenting = RecoveryPhraseBadgePresenter(provider: recoveryStatusProviding)
    }
}
