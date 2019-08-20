//
//  HDWalletKitError.swift
//  HDWalletKit
//
//  Created by Jack on 18/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum HDWalletKitError: Error {
    case unknown
    case libWallyError(Error)
}
