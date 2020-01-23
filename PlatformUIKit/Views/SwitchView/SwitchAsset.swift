//
//  SwitchAsset.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public struct SwitchInteractionAsset {
    
    public let isOn: Bool
    public let isEnabled: Bool
    
    public init(isOn: Bool, isEnabled: Bool) {
        self.isOn = isOn
        self.isEnabled = isEnabled
    }
}
