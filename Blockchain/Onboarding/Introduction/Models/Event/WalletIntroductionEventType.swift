//
//  WalletIntroductionStep.swift
//  Blockchain
//
//  Created by AlexM on 8/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

enum WalletIntroductionEventType {
    
    // An event that displays a `Pulse` over a given view.
    case pulse(WalletIntroductionPulseViewModel)
    
    // An event that present an `IntroductionSheetViewController`
    case sheet(IntroductionSheetViewModel)
    
    // A no-op event
    case none
}
