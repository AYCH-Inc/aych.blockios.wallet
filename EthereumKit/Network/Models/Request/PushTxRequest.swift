//
//  PushTxRequest.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct PushTxRequest: Encodable {
    let rawTx: String
    let api_code: String
}
