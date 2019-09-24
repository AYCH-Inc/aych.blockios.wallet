//
//  UnspentOutputs.swift
//  BitcoinKit
//
//  Created by Jack on 08/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import PlatformKit

enum UnspentOutputError: Error {
    case invalidValue
}

struct UnspentOutputs: Equatable {
    
    let outputs: [UnspentOutput]
}

extension UnspentOutputs {
    init(networkResponse: UnspentOutputsResponse) {
        self.outputs = networkResponse
            .unspent_outputs
            .compactMap { try? UnspentOutput(response: $0) }
    }
}


