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

        let minimum = baseReserve * 2

        let current = String(format: LocalizationConstants.Stellar.minimumBalanceInfoCurrentArgument, "\(minimum)".appendAssetSymbol(for: assetType))

        let total = Decimal(string: "827.6802382")!
        let totalText = LocalizationConstants.Stellar.totalFundsLabel
        let totalAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: total,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let requirementText = LocalizationConstants.Stellar.xlmReserveRequirement
        let requirementAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: minimum,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let fee = Decimal(string: "0.001")!
        let feeText = LocalizationConstants.Stellar.transactionFee
        let feeAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: fee,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let availableToSend = total - minimum - fee
        let availableToSendText = LocalizationConstants.Stellar.availableToSend
        let availableToSendAmount = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
            fromAmount: availableToSend,
            fiatPerAmount: latestPrice,
            assetType: assetType
        )
        let moreInformationText = LocalizationConstants.Stellar.minimumBalanceMoreInformation

        let defaultFont = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)!
        let defaultAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: UIColor.gray5,
                                 NSAttributedStringKey.font: defaultFont]

        let explanationPlusCurrent = NSAttributedString(
            string: "\(explanation)\n\n\(current)\n\n",
            attributes: defaultAttributes
        )
        let exampleOne = NSAttributedString(
            string: "\(totalText)\n\(totalAmount)\n\n\(requirementText)\n\(requirementAmount)\n\n",
            attributes: defaultAttributes
        )
        let exampleTwo = NSAttributedString(
            string: "\(feeText)\n\(feeAmount)\n\n",
            attributes: defaultAttributes
        )
        let available = NSAttributedString(
            string: "\(availableToSendText)\n\(availableToSendAmount)\n\n",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.black,
                         NSAttributedStringKey.font: UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.Small)!]
        )
        let footer = NSAttributedString(
            string: "\(moreInformationText)",
            attributes: defaultAttributes
        )

        let body = NSMutableAttributedString()
        [explanationPlusCurrent, exampleOne, exampleTwo, available, footer].forEach { body.append($0)
        }
        return body.copy() as! NSAttributedString
    }
}
