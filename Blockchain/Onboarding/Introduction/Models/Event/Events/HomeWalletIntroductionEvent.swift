//
//  HomeWalletIntroductionEvent.swift
//  Blockchain
//
//  Created by AlexM on 8/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

final class HomeWalletIntroductionEvent: CompletableWalletIntroductionEvent {
    
    var type: WalletIntroductionEventType {
        let location: WalletIntroductionLocation = .init(
            screen: .dashboard,
            position: .home
        )
        
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
        guard let _ = introductionEntry.value else { return true }
        return false
    }
    
    init(introductionRecorder: WalletIntroductionRecorder = WalletIntroductionRecorder(),
        selection: @escaping WalletIntroductionAction) {
        self.introductionRecorder = introductionRecorder
        self.selection = selection
    }
}

final class HomeDescriptionWalletIntroductionEvent: WalletIntroductionEvent, WalletIntroductionAnalyticsEvent {
    
    var type: WalletIntroductionEventType {
        
        let viewModel = IntroductionSheetViewModel(
            title: LocalizationConstants.Onboarding.IntroductionSheet.Home.title,
            description: LocalizationConstants.Onboarding.IntroductionSheet.Home.description,
            thumbnail: #imageLiteral(resourceName: "Icon-Home"),
            onSelection: {
                self.selection()
            }
        )
        
        return .sheet(viewModel)
    }
    
    let selection: WalletIntroductionAction
    
    var eventType: WalletIntroductionAnalyticsEventType {
        return .portfolioViewed
    }
    
    var shouldShow: Bool {
        return true
    }
    
    init(selection: @escaping WalletIntroductionAction) {
        self.selection = selection
    }
}
