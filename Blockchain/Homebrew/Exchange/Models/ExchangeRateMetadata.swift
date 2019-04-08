//
//  ExchangeRateMetadata.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum ExchangeRateDescriptionType {
    case fromAssetToFiat
    case toAssetToFiat
    case fromAssetToAsset
}

extension ExchangeRateDescriptionType {
    func next() -> ExchangeRateDescriptionType {
        switch self {
        case .fromAssetToAsset:
            return .fromAssetToFiat
        case .fromAssetToFiat:
            return .toAssetToFiat
        case .toAssetToFiat:
            return .fromAssetToAsset
        }
    }
}

struct ExchangeRateMetadata {
    let currencyCode: String
    let fromAsset: AssetType
    let toAsset: AssetType
    private let rates: [CurrencyPairRate]
    
    init(
        currencyCode: String,
        fromAsset: AssetType,
        toAsset: AssetType,
        rates: [CurrencyPairRate]
        ) {
        self.currencyCode = currencyCode
        self.fromAsset = fromAsset
        self.toAsset = toAsset
        self.rates = rates
    }
}

extension ExchangeRateMetadata {
    
    func description(
        for type: ExchangeRateDescriptionType,
        font: UIFont,
        fromColor: UIColor,
        toColor: UIColor
        ) -> NSAttributedString {
        let empty = NSAttributedString(string: "\n\n", attributes: [.font: font])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        switch type {
        case .fromAssetToFiat:
            guard let descriptor = fromAssetToFiatDescriptor else { return empty }
            let first = NSAttributedString(
                string: fromAssetRateDescriptor,
                attributes: [.font: font,
                             .foregroundColor: fromColor,
                             .paragraphStyle: paragraphStyle]
            )
            let second = NSAttributedString(
                string: descriptor,
                attributes: [.font: font,
                             .foregroundColor: toColor,
                             .paragraphStyle: paragraphStyle]
            )
            let result = [first, second].join(withSeparator: .lineBreak())
            return result
        case .toAssetToFiat:
            guard let descriptor = toAssetToFiatDescriptor else { return empty }
            let first = NSAttributedString(
                string: toAssetRateDescriptor,
                attributes: [.font: font,
                             .foregroundColor: fromColor,
                             .paragraphStyle: paragraphStyle]
            )
            let second = NSAttributedString(
                string: descriptor,
                attributes: [.font: font,
                             .foregroundColor: toColor,
                             .paragraphStyle: paragraphStyle]
            )
            let result = [first, second].join(withSeparator: .lineBreak())
            return result
        case .fromAssetToAsset:
            guard let descriptor = fromAssetToAssetDescriptor else { return empty }
            let first = NSAttributedString(
                string: fromAssetRateDescriptor,
                attributes: [.font: font,
                             .foregroundColor: fromColor,
                             .paragraphStyle: paragraphStyle]
            )
            let second = NSAttributedString(
                string: descriptor,
                attributes: [.font: font,
                             .foregroundColor: toColor,
                             .paragraphStyle: paragraphStyle]
            )
            let result = [first, second].join(withSeparator: .lineBreak())
            return result
        }
    }
    
    var fromAssetRateDescriptor: String {
        return "1 \(fromAsset.symbol) ="
    }
    
    var toAssetRateDescriptor: String {
        return "1 \(toAsset.symbol) ="
    }
    
    var fromAssetToFiatDescriptor: String? {
        guard let rate = rates.last(where: { $0.pair == "\(fromAsset.symbol)-\(currencyCode)"}) else { return nil }
        return "\(rate.price) \(currencyCode)"
    }
    
    var toAssetToFiatDescriptor: String? {
        guard let rate = rates.last(where: { $0.pair == "\(toAsset.symbol)-\(currencyCode)"}) else { return nil }
        return "\(rate.price) \(currencyCode)"
    }
    
    var fromAssetToAssetDescriptor: String? {
        guard let rate = rates.last(where: { $0.pair == "\(fromAsset.symbol)-\(toAsset.symbol)"}) else { return nil }
        return "\(rate.price) \(toAsset.symbol)"
    }
}
