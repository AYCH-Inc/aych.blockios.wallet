//
//  SwapWalletIntroductionEvent.swift
//  Blockchain
//
//  Created by AlexM on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

final class SwapWalletIntroductionEvent: CompletableWalletIntroductionEvent {
    
    private static let location: WalletIntroductionLocation = .init(
        screen: .dashboard,
        position: .swap
    )
    
    var type: WalletIntroductionEventType {
        let location = SwapWalletIntroductionEvent.location
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
        return SwapWalletIntroductionEvent.location > location
    }
    
    init(introductionRecorder: WalletIntroductionRecorder = WalletIntroductionRecorder(),
         selection: @escaping WalletIntroductionAction) {
        self.introductionRecorder = introductionRecorder
        self.selection = selection
    }
}

final class SwapDescriptionIntroductionEvent: WalletIntroductionEvent, WalletIntroductionAnalyticsEvent {
    
    var type: WalletIntroductionEventType {
        let viewModel = IntroductionSheetViewModel(
            title: LocalizationConstants.Onboarding.IntroductionSheet.Swap.title,
            description: LocalizationConstants.Onboarding.IntroductionSheet.Swap.description,
            thumbnail: #imageLiteral(resourceName: "Icon-Swap"),
            onSelection: {
                self.selection()
        }
        )
        
        return .sheet(viewModel)
    }
    
    let selection: WalletIntroductionAction
    
    var eventType: WalletIntroductionAnalyticsEventType {
        return .swapViewed
    }
    
    var shouldShow: Bool {
        return true
    }
    
    init(selection: @escaping WalletIntroductionAction) {
        self.selection = selection
    }
}
