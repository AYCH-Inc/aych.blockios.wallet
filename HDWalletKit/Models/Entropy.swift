//
//  Entropy.swift
//  HDWalletKit
//
//  Created by Jack on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import CommonCryptoKit

public struct Entropy: HexRepresentable {
    
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }

    // TODO:
    // * This needs to be rewritten with a proper source of entropy
    @available(*, deprecated, message: "Don't use this! this is insecure")
    public static func create(size: Int) -> Entropy {
        let byteCount = size / 8
        var bytes = Data(count: byteCount)
        _ = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, byteCount, $0) }
        return Entropy(data: bytes)
    }
}
