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
    ) -> String {
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
        let explanationPlusCurrent = "\(explanation)\n\n\(current)\n\n"
        let exampleOne = "\(total)\n\(totalAmount)\n\n\(requirement)\n\(requirementAmount)"
        let exampleTwo = "\n\n\(fee)\n\(feeAmount)\n\n\(availableToSend)\n\(availableToSendAmount)\n\n"
        let footer = "\(moreInformation)"

        return explanationPlusCurrent + exampleOne + exampleTwo + footer
    }
}
