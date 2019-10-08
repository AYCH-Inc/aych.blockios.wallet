//
//  BuySellWalletIntroductionEvent.swift
//  Blockchain
//
//  Created by AlexM on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit

final class BuySellWalletIntroductionEvent: CompletableWalletIntroductionEvent {
    
    private static let location: WalletIntroductionLocation = .init(
        screen: .sideMenu,
        position: .buySell
    )
    
    var type: WalletIntroductionEventType {
        let location = BuySellWalletIntroductionEvent.location
        let viewModel = WalletIntroductionPulseViewModel(
            location: location,
            action: {
                self.introductionEntry.updateLatestLocation(location)
                self.selection()
        })
        return .pulse(viewModel)
    }
    
    let selection: WalletIntroductionAction
    
    let introductionRecorder: WalletIntroductionRecorder
    
    var introductionEntry: WalletIntroductionRecorder.Entry {
        return introductionRecorder[UserDefaults.Keys.walletIntroLatestLocation.rawValue]
    }
    
    var shouldShow: Bool {
        guard let location = introductionEntry.value else { return true }
        return BuySellWalletIntroductionEvent.location > location
    }
    
    init(introductionRecorder: WalletIntroductionRecorder = WalletIntroductionRecorder(),
         selection: @escaping WalletIntroductionAction) {
        self.introductionRecorder = introductionRecorder
        self.selection = selection
    }
}

final class BuySellDescriptionIntroductionEvent: WalletIntroductionEvent, WalletIntroductionAnalyticsEvent {
    
    var type: WalletIntroductionEventType {
        let viewModel = IntroductionSheetViewModel(
            title: LocalizationConstants.Onboarding.IntroductionSheet.BuySell.title,
            description: LocalizationConstants.Onboarding.IntroductionSheet.BuySell.description,
            buttonTitle: LocalizationConstants.Onboarding.IntroductionSheet.done,
            thumbnail: #imageLiteral(resourceName: "Icon-Cart"),
            onSelection: {
                self.selection()
        }
        )
        
        return .sheet(viewModel)
    }
    
    let selection: WalletIntroductionAction
    
    var eventType: AnalyticsEvents.WalletIntro {
        return .walletIntroBuysellViewed
    }
    
    var shouldShow: Bool {
        return true
    }
    
    init(selection: @escaping WalletIntroductionAction) {
        self.selection = selection
    }
}
