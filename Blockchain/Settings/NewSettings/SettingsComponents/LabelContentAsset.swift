//
//  LabelContentAsset.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

public struct LabelContentAsset {
    
    public struct State {
        
        /// The state of the `LabelItem` interactor and presenter
        public struct LabelItem {
            public typealias Interaction = LoadingState<Value.Interaction.LabelItem>
            public typealias Presentation = LoadingState<Value.Presentation.LabelItem>
        }
    }
    
    public struct Value {
        public struct Interaction {
            public struct LabelItem {
                public let text: String
            }
        }
        
        public struct Presentation {
            
            public struct LabelItem {
                
                /// Descriptors that allows customized content and style
                public struct Descriptors {
                    let titleFontSize: CGFloat
                    let accessibilityIdSuffix: String
                }
                
                let labelContent: LabelContent
                
                public init(with value: Interaction.LabelItem, descriptors: Descriptors) {
                    labelContent = LabelContent(
                        text: value.text,
                        font: .mainMedium(descriptors.titleFontSize),
                        color: .titleText,
                        accessibility: .init(id: .value(descriptors.accessibilityIdSuffix))
                    )
                }
            }
        }
    }
}

extension LabelContentAsset.Value.Presentation.LabelItem.Descriptors {
    
    /// Returns a descriptor for a settings cell
    public static var settings: LabelContentAsset.Value.Presentation.LabelItem.Descriptors {
        return .init(
            titleFontSize: 16,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }
}

extension LoadingState where Content == LabelContentAsset.Value.Presentation.LabelItem {
    init(with state: LoadingState<LabelContentAsset.Value.Interaction.LabelItem>,
         descriptors: LabelContentAsset.Value.Presentation.LabelItem.Descriptors) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content,
                    descriptors: descriptors
                )
            )
        }
    }
}

