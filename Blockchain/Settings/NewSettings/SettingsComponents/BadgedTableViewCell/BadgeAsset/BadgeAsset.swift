//
//  BadgeAsset.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

public struct BadgeAsset {
    
    public struct State {
        
        /// The state of the `BadgeItem` interactor and presenter
        public struct BadgeItem {
            public typealias Interaction = LoadingState<Value.Interaction.BadgeItem>
            public typealias Presentation = LoadingState<Value.Presentation.BadgeItem>
        }
    }
    
    public struct Value {
        public struct Interaction {
            public struct BadgeItem: Equatable {
                
                public enum BadgeType: Equatable {
                    case `default`
                    case verified
                    case destructive
                }
                
                public let type: BadgeType
                
                // TODO-Settings: Should not be in the interaction layer
                public let description: String
            }
        }
        
        public struct Presentation {
            public struct BadgeItem {
                
                let viewModel: BadgeViewModel
                
                public init(with value: Interaction.BadgeItem) {
                    switch value.type {
                    case .default:
                        viewModel = .default(with: value.description)
                    case .destructive:
                        viewModel = .destructive(with: value.description)
                    case .verified:
                        viewModel = .affirmative(with: value.description)
                    }
                }
            }
        }
    }
}

extension BadgeAsset.Value.Interaction.BadgeItem {
    static let verified: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .verified,
        description: LocalizationConstants.verified
    )
    
    static let unverified: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .destructive,
        description: LocalizationConstants.unverified
    )
    
    static let connect: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .default,
        description: LocalizationConstants.Exchange.connect
    )
    
    static let confirmed: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .default,
        description: LocalizationConstants.Settings.Badge.confirmed
    )
    
    static let unconfirmed: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .destructive,
        description: LocalizationConstants.Settings.Badge.unconfirmed
    )
    
    static let connected: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .default,
        description: LocalizationConstants.Exchange.connected
    )
}

extension LoadingState where Content == BadgeAsset.Value.Presentation.BadgeItem {
    init(with state: LoadingState<BadgeAsset.Value.Interaction.BadgeItem>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content
                )
            )
        }
    }
}

