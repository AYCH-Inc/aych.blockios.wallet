//
//  AirdropTypeCellPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

struct AirdropTypeCellPresenter {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.Airdrop.CenterScreen.Cell
    private typealias AccessibilityId = Accessibility.Identifier.AirdropCenterScreen.Cell

    // MARK: - Properties
    
    let title: LabelContent
    let description: LabelContent
    let image: ImageViewContent
        
    var campaignIdentifier: String {
        return interactor.campaignIdentifier
    }
    
    // MARK: - Injected
    
    private let interactor: AirdropTypeCellInteractor
    
    // MARK: - Setup
    
    init(interactor: AirdropTypeCellInteractor) {
        self.interactor = interactor
        image = ImageViewContent(
            image: interactor.cryptoCurrency.logoImage,
            accessibility: .id(AccessibilityId.image)
        )
        let title: String
        if let value = interactor.fiatValue {
            title = String(
                format: LocalizedString.fiatTitle,
                value.toDisplayString(includeSymbol: true),
                interactor.cryptoCurrency.symbol
            )
        } else {
            /// If the fiat value is missing, then it was not returned by the backend.
            /// make sure to display something.
            title = interactor.cryptoCurrency.symbol
        }

        self.title = .init(
            text: title,
            font: .mainMedium(16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.title)\(interactor.campaignIdentifier)")
        )
        let description: String
        if let dropDate = interactor.dropDate {
            let date = DateFormatter.nominalReadable.string(from: dropDate)
            let format: String
            if interactor.isAvailable {
                format = LocalizedString.availableDescription
            } else {
                format = LocalizedString.endedDescription
            }
            description = String(format: format, date)
        } else { // Empty description
            description = ""
        }
        self.description = .init(
            text: description,
            font: .mainMedium(12),
            color: .descriptionText,
            accessibility: .id("\(AccessibilityId.title)\(interactor.campaignIdentifier)")
        )
    }
}
