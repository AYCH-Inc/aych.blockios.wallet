//
//  RequestWalletIntroductionEvent.swift
//  Blockchain
//
//  Created by AlexM on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

final class RequestWalletIntroductionEvent: CompletableWalletIntroductionEvent {
    
    private static let location: WalletIntroductionLocation = .init(
        screen: .dashboard,
        position: .request
    )
    
    var type: WalletIntroductionEventType {
        let location = RequestWalletIntroductionEvent.location
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
        return RequestWalletIntroductionEvent.location > location
    }
    
    init(introductionRecorder: WalletIntroductionRecorder = WalletIntroductionRecorder(),
         selection: @escaping WalletIntroductionAction) {
        self.introductionRecorder = introductionRecorder
        self.selection = selection
    }
}

final class RequestDescriptionIntroductionEvent: WalletIntroductionEvent, WalletIntroductionAnalyticsEvent {
    
    var type: WalletIntroductionEventType {
        let viewModel = IntroductionSheetViewModel(
            title: LocalizationConstants.Onboarding.IntroductionSheet.Request.title,
            description: LocalizationConstants.Onboarding.IntroductionSheet.Request.description,
            buttonTitle: LocalizationConstants.Onboarding.IntroductionSheet.next,
            thumbnail: #imageLiteral(resourceName: "Icon-Receive"),
            onSelection: {
                self.selection()
        })
        return .sheet(viewModel)
    }
    
    let selection: WalletIntroductionAction
    
    var eventType: WalletIntroductionAnalyticsEventType {
        return .requestViewed
    }
    
    var shouldShow: Bool {
        return true
    }
    
    init(selection: @escaping WalletIntroductionAction) {
        self.selection = selection
    }
}
