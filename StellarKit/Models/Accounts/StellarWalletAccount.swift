//
//  StellarWalletAccount.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct StellarWalletAccount: WalletAccount, Codable {
    public var index: Int
    public var publicKey: String
    public var label: String?
    public var archived: Bool
    
    public init(index: Int, publicKey: String, label: String? = nil, archived: Bool = false) {
        self.index = index
        self.publicKey = publicKey
        self.label = label
        self.archived = archived
    }
    
    enum CodingKeys: String, CodingKey {
        case index
        case publicKey
        case label
        case archived
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        publicKey = try values.decode(String.self, forKey: .publicKey)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        archived = try values.decode(Bool.self, forKey: .archived)
        
        // TODO: Not sure that this is needed on `WalletAccount`.
        index = 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(publicKey)
        try container.encode(label)
        try container.encode(archived)
    }
}
