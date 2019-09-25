//
//  String+SHA256.swift
//  CommonCryptoKit
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    public var sha256: String {
        guard let string = data(using: .utf8) else {
            return ""
        }
        let hashedData = digest(input: string as NSData)
        let hashedString = hexStringFromData(input: hashedData)
        return hashedString
    }

    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
}
