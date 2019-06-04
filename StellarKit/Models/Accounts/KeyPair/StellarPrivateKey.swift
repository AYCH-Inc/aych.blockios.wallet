//
//  StellarPrivateKey.swift
//  StellarKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct StellarPrivateKey {
    public var secret: String
    
    public init(secret: String) {
        self.secret = secret
    }
}
