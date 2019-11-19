//
//  AirdropIntroScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit

final class AirdropIntroScreenPresenter {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.AirdropIntroScreen
    private typealias LocalizedString = LocalizationConstants.Airdrop.IntroScreen

    // MARK: - Properties
    
    let amount: LabelContent
    let title: LabelContent
    let subtitle: LabelContent
    let disclaimerViewModel: InteractableTextViewModel
    let cellPresenters: [AirdropIntroCellPresenter]
    let buttonViewModel: ButtonViewModel
    
    /// Returns the count of cells
    var cellCount: Int {
        return cellPresenters.count
    }
    
    // MARK: - Injected
    
    private let interactor: AirdropIntroScreenInteractor
    
    // MARK: - Setup
    
    init(interactor: AirdropIntroScreenInteractor = AirdropIntroScreenInteractor()) {
        self.interactor = interactor
        amount = .init(
            text: interactor.fiatAmount.toDisplayString(),
            font: .mainMedium(56),
            color: .titleText,
            accessibility: .id(AccessibilityId.amountLabel)
        )
        title = .init(
            text: LocalizedString.title,
            font: .mainMedium(20),
            color: .titleText,
            accessibility: .id(AccessibilityId.titleLabel)
        )
        subtitle = .init(
            text: LocalizedString.subtitle,
            font: .mainMedium(14),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.subtitleLabel)
        )
        
        let disclaimerFont = UIFont.mainMedium(12)
        disclaimerViewModel = InteractableTextViewModel(
            inputs: [
                .text(string: LocalizedString.disclaimerPrefix),
                .url(string: LocalizedString.disclaimerLearnMoreLink,
                     url: Constants.Url.termsOfService)
            ],
            textStyle: .init(color: .descriptionText, font: disclaimerFont),
            linkStyle: .init(color: .linkableText, font: disclaimerFont)
        )
        
        cellPresenters = [
            .init(data:
                AirdropIntroCellData(
                    title: .init(
                        text: LocalizedString.InfoCell.Number.title,
                        accessibility: .id(AccessibilityId.InfoCell.numberTitle)
                    ),
                    value: .init(
                        text: LocalizedString.InfoCell.Number.value,
                        accessibility: .id(AccessibilityId.InfoCell.numberValue)
                    )
                )
            ),
            .init(data:
                AirdropIntroCellData(
                    title: .init(
                        text: LocalizedString.InfoCell.Currency.title,
                        accessibility: .id(AccessibilityId.InfoCell.currencyTitle)
                    ),
                    value: .init(
                        text: LocalizedString.InfoCell.Currency.value,
                        accessibility: .id(AccessibilityId.InfoCell.currencyValue)
                    )
                )
            )
        ]
        
        var buttonViewModel = ButtonViewModel(
            accessibility: .init(id: .value(Accessibility.Identifier.General.mainCTAButton))
        )
        buttonViewModel.theme = ButtonViewModel.Theme(
            backgroundColor: .airdropCTAButton,
            contentColor: .white,
            text: LocalizedString.ctaButton
        )
        self.buttonViewModel = buttonViewModel
    }
}
