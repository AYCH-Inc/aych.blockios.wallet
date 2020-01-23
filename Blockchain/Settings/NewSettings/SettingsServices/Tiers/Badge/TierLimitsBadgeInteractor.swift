//
//  TierLimitsBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class TierLimitsBadgeInteractor: BadgeAssetInteracting {
    
    typealias InteractionState = BadgeAsset.State.BadgeItem.Interaction
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(limitsProviding: TierLimitsProviding) {
        limitsProviding.tiers.map { $0.interactionModel }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

fileprivate extension KYCUserTiersResponse {
    
    var interactionModel: BadgeAsset.State.BadgeItem.Interaction {
        // TODO: Update with correct copy + Localization
        let locked: BadgeAsset.State.BadgeItem.Interaction = .loaded(next: .locked)
        
        guard userTiers.count > 0 else { return locked }
        guard let tier1 = userTiers.filter({ $0.tier == .tier1 }).first else { return locked }
        guard let tier2 = userTiers.filter({ $0.tier == .tier2 }).first else { return locked }
        
        let currentTier = tier2.state != .none ? tier2 : tier1
        
        switch currentTier.state {
        case .none:
            return .loaded(next: .init(type: .default, description: LocalizationConstants.KYC.accountUnverifiedBadge))
        case .rejected:
            return .loaded(next: .init(type: .destructive, description: LocalizationConstants.KYC.verificationFailedBadge))
        case .pending:
            return .loaded(next: .init(type: .default, description: LocalizationConstants.KYC.accountInReviewBadge))
        case .verified:
            return .loaded(next: .init(type: .verified, description: LocalizationConstants.KYC.accountApprovedBadge))
        }
    }
}

fileprivate extension BadgeAsset.Value.Interaction.BadgeItem {
    typealias Model = BadgeAsset.Value.Interaction.BadgeItem
    static let locked: Model = .init(type: .destructive, description: LocalizationConstants.Settings.Badge.Limits.failed)
}
