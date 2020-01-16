//
//  MockPastboard.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@testable import Blockchain

class MockPasteboard: Pasteboarding {
    var string: String?
    var image: UIImage?
}
