//
//  StellarMinimumRequirementInformationFormatter.swift
//  Blockchain
//
//  Created by kevinwu on 11/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class StellarInformationService {
    static func formattedMinimumRequirementInformationText(
        baseReserve: Decimal,
        latestPrice: Decimal
    ) -> NSAttributedString {
        let assetType: AssetType = .stellar
        let explanation = LocalizationConstants.Stellar.minimumBalanceInfoExplanation

        let current = String(format: LocalizationConstants.Stellar.minimumBalanceInfoCurrentArgument, "\(baseReserve)".appendAssetSymbol(for: assetType))

        let total = LocalizationConstants.Stellar.totalFundsLabel
        let totalAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: Decimal(string: "827.6802382")!,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let requirement = LocalizationConstants.Stellar.xlmReserveRequirement
        let requirementAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: Decimal(string: "2")!,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let fee = LocalizationConstants.Stellar.transactionFee
        let feeAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: Decimal(string: "0.001")!,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let availableToSend = LocalizationConstants.Stellar.availableToSend
        let availableToSendAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: Decimal(string: "825.6792382")!,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let moreInformation = LocalizationConstants.Stellar.minimumBalanceMoreInformation

        let defaultFont = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)!
        let defaultAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: UIColor.gray5,
                                 NSAttributedStringKey.font: defaultFont]

        let explanationPlusCurrent = NSAttributedString(
            string: "\(explanation)\n\n\(current)\n\n",
            attributes: defaultAttributes
        )
        let exampleOne = NSAttributedString(
            string: "\(total)\n\(totalAmount)\n\n\(requirement)\n\(requirementAmount)\n\n",
            attributes: defaultAttributes
        )
        let exampleTwo = NSAttributedString(
            string: "\(fee)\n\(feeAmount)\n\n",
            attributes: defaultAttributes
        )
        let available = NSAttributedString(
            string: "\(availableToSend)\n\(availableToSendAmount)\n\n",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.black,
                         NSAttributedStringKey.font: UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.Small)!]
        )
        let footer = NSAttributedString(
            string: "\(moreInformation)",
            attributes: defaultAttributes
        )

        let body = NSMutableAttributedString()
        [explanationPlusCurrent, exampleOne, exampleTwo, available, footer].forEach { body.append($0)
        }
        return body.copy() as! NSAttributedString
    }
}
