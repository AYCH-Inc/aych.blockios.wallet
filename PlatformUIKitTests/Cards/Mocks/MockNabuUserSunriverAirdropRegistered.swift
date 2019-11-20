//
//  MockNabuUserSunriverAirdropRegistered.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 29/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import PlatformKit

struct MockNabuUserSunriverAirdropRegistered: NabuUserSunriverAirdropRegistering {
    let isSunriverAirdropRegistered: Bool
    init(isRegistered: Bool) {
        self.isSunriverAirdropRegistered = isRegistered
    }
}
