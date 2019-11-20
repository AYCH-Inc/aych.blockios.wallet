//
//  DashboardAssetPrice.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct DashboardAsset {
    
    // MARK: - State Aliases
    
    public struct State {
        
        /// The state of the `AssetPrice` interactor and presenter
        public struct AssetPrice {
            public typealias Interaction = LoadingState<Value.Interaction.AssetPrice>
            public typealias Presentation = LoadingState<Value.Presentation.AssetPrice>
        }
        
        /// The state of the `AssetBalance` interactor and presenter
        public struct AssetBalance {
            public typealias Interaction = LoadingState<Value.Interaction.AssetBalance>
            public typealias Presentation = LoadingState<Value.Presentation.AssetBalance>
        }
    }
    
    // MARK: - Value Namespace
    
    public struct Value {
        
        // MARK: - Interaction
        
        /// The interaction value of dashboard asset
        public struct Interaction {
            
            public struct AssetPrice {
                /// The asset price in localized fiat currency
                let fiatValue: FiatValue
                
                /// Percentage of change since a certain time
                let changePercentage: Double
                
                /// The change in fiat value
                let fiatChange: FiatValue
            }
            
            public struct AssetBalance {
                
                /// The wallet's balance in fiat
                let fiatValue: FiatValue
                /// The wallet's balance in crypto
                let cryptoValue: CryptoValue
            }
            
        }
        
        // MARK: - Presentation
        
        public struct Presentation {
            
            /// The presentation model for `AssetBalanceView`
            public struct AssetBalance {
                
                private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell
                
                // MARK: - Properties
                
                /// The balance in fiat
                let fiatBalance: LabelContent
                
                /// The balance in crypto
                let cryptoBalance: LabelContent
                
                // MARK: - Setup
                
                public init(with value: Interaction.AssetBalance) {
                    fiatBalance = LabelContent(
                        text: value.fiatValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: .mainMedium(16.0),
                        color: .dashboardFiatPriceTitle,
                        accessibility: .init(
                            id: .value("\(AccessibilityId.fiatBalanceLabelFormat)\(value.cryptoValue.currencyCode)")
                            )
                        )
                    
                    cryptoBalance = LabelContent(
                        text: value.cryptoValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: .mainMedium(14.0),
                        color: .mutedText,
                        accessibility: .init(
                            id: .value("\(AccessibilityId.cryptoBalanceLabelFormat)\(value.cryptoValue.currencyCode)")
                            )
                        )
                }
            }
            
            /// The presentation model for `AssetPriceView`
            public struct AssetPrice {
                
                private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

                /// Descriptors that allows customized content and style
                public struct Descriptors {
                    
                    /// Time unit. Can be further customized in future
                    /// Each value currently refers to 1 unit
                    public enum Time {
                        case hours(Int)
                        case days(Int)
                        case weeks(Int)
                        case months(Int)
                        case years(Int)
                        
                        public var string: String {
                            switch self {
                            case .hours(let number):
                                return "\(number)\(LocalizationConstants.TimeUnit.hours)"
                            case .days(let number):
                                return "\(number)\(LocalizationConstants.TimeUnit.days)"
                            case .weeks(let number):
                                return "\(number)\(LocalizationConstants.TimeUnit.weeks)"
                            case .months(let number):
                                return "\(number)\(LocalizationConstants.TimeUnit.months)"
                            case .years(let number):
                                return "\(number)\(LocalizationConstants.TimeUnit.years)"
                            }
                        }
                    }
                    
                    /// Options to display content
                    struct ContentOptions: OptionSet {
                        let rawValue: Int
                        init(rawValue: Int) {
                            self.rawValue = rawValue
                        }
                        
                        /// Includes fiat price change
                        static let fiat = ContentOptions(rawValue: 1 << 0)
                        
                        /// Includes percentage price change
                        static let percentage = ContentOptions(rawValue: 2 << 0)
                    }
                    
                    let contentOptions: ContentOptions
                    let time: Time
                    let priceFontSize: CGFloat
                    let changeFontSize: CGFloat
                    let accessibilityIdSuffix: String
                }
                
                // MARK: - Properties
                
                /// The price of the asset
                let price: LabelContent
                
                /// The change
                let change: NSAttributedString
                
                let changeAccessibility: Accessibility
                
                // MARK: - Setup
                
                public init(with value: Interaction.AssetPrice, descriptors: Descriptors) {
                    let fiatPrice = value.fiatValue.toDisplayString(includeSymbol: true)
                    price = LabelContent(
                        text: fiatPrice,
                        font: .mainSemibold(descriptors.priceFontSize),
                        color: .dashboardAssetTitle,
                        accessibility: .init(
                            id: .value("\(AccessibilityId.fiatBalanceLabelFormat)\(descriptors.accessibilityIdSuffix)")
                        )
                    )
                    
                    let color: UIColor
                    let sign: String
                    
                    if value.fiatChange.isPositive {
                        sign = "+"
                        color = .positivePrice
                    } else if value.fiatChange.isNegative {
                        sign = ""
                        color = .negativePrice
                    } else { // Zero {
                        sign = ""
                        color = .mutedText
                    }
                    
                    let fiatChange: NSAttributedString
                    if descriptors.contentOptions.contains(.fiat) {
                        let fiat = value.fiatChange.toDisplayString(includeSymbol: true)
                        let suffix = descriptors.contentOptions.contains(.percentage) ? " " : ""
                        fiatChange = NSAttributedString(
                            LabelContent(
                                text: "\(sign)\(fiat)\(suffix)",
                                font: .mainMedium(descriptors.changeFontSize),
                                color: color
                            )
                        )
                    } else {
                        fiatChange = NSAttributedString()
                    }
                    
                    let percentageChange: NSAttributedString
                    if descriptors.contentOptions.contains(.percentage) {
                        let prefix: String
                        let suffix: String
                        if descriptors.contentOptions.contains(.fiat) {
                            prefix = "("
                            suffix = ")"
                        } else {
                            prefix = ""
                            suffix = ""
                        }
                        let percentage = value.changePercentage * 100
                        let percentageString = percentage.string(with: 2)
                        percentageChange = NSAttributedString(
                            LabelContent(
                                text: "\(prefix)\(percentageString)%\(suffix)",
                                font: .mainMedium(descriptors.changeFontSize),
                                color: color
                            )
                        )
                    } else {
                        percentageChange = NSAttributedString()
                    }
                    
                    let period = NSAttributedString(
                        LabelContent(
                            text: " \(descriptors.time.string)",
                            font: .mainMedium(descriptors.changeFontSize),
                            color: .mutedText
                        )
                    )
                    change = fiatChange + percentageChange + period
                    changeAccessibility = .init(id: .value("\(AccessibilityId.changeLabelFormat)\(descriptors.accessibilityIdSuffix)"
                    ))
                }
            }
        }
    }
}

extension DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
    
    /// Returns a descriptor for dashboard total balance
    public static var balance: DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        return .init(
            contentOptions: [.fiat, .percentage],
            time: .hours(24),
            priceFontSize: 24,
            changeFontSize: 14,
            accessibilityIdSuffix: Accessibility.Identifier.Dashboard.TotalBalanceCell.valueLabelSuffix
        )
    }
    
    /// Returns a descriptor for dashboard asset price
    public static func assetPrice(accessibilityIdSuffix: String) -> DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        return .init(
            contentOptions: [.percentage],
            time: .hours(24),
            priceFontSize: 16,
            changeFontSize: 14,
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }
}
