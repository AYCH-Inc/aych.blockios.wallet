//
//  WalletIntroductionPulseViewModel.swift
//  Blockchain
//
//  Created by AlexM on 8/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

struct WalletIntroductionPulseViewModel {
    typealias PulseTapAction = () -> Void
    
    // The location of the pulse
    let location: WalletIntroductionLocation
    
    // The action that is executed when the pulse is tapped
    let action: PulseTapAction
}
