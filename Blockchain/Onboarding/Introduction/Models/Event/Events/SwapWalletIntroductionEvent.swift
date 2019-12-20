//
//  SwapWalletIntroductionEvent.swift
//  Blockchain
//
//  Created by AlexM on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
import PlatformKit
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
            buttonTitle: buttonTitle,
            thumbnail: #imageLiteral(resourceName: "Icon-Swap"),
            onSelection: {
                self.selection()
        }
        )
        
        return .sheet(viewModel)
    }
    
    let selection: WalletIntroductionAction
    
    var eventType: AnalyticsEvents.WalletIntro {
        return .walletIntroSwapViewed
    }
    
    var shouldShow: Bool {
        return true
    }
    
    private var buttonTitle: String {
        /// If `Buy` is enabled, the user will see an additional
        /// introduction event. 
        switch isBuyEnabled {
        case true:
            return LocalizationConstants.Onboarding.IntroductionSheet.next
        case false:
            return LocalizationConstants.Onboarding.IntroductionSheet.done
        }
    }
    
    private let isBuyEnabled: Bool
    
    init(isBuyEnabled: Bool, selection: @escaping WalletIntroductionAction) {
        self.isBuyEnabled = isBuyEnabled
        self.selection = selection
    }
}
