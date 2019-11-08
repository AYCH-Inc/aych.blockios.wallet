//
//  InfoScreenContent.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

struct AirdropInfoScreenContent: InfoScreenContent {
    
    private typealias LocalizedString = LocalizationConstants.InfoScreen.Airdrop
    
    let image = "airdrop_icon"
    let title = LocalizedString.title
    let description = LocalizedString.description
    let note = LocalizedString.note
    let buttonTitle = LocalizedString.ctaButton
}

struct STXApplicationCompleteInfoScreenContent: InfoScreenContent {
    
    private typealias LocalizedString = LocalizationConstants.InfoScreen.STXApplicationComplete
    
    let image = "success_icon"
    let title = LocalizedString.title
    let description = LocalizedString.description
    let note = LocalizedString.note
    let buttonTitle = LocalizedString.ctaButton
}
