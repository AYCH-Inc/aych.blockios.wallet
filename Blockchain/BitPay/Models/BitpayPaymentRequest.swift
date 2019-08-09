//
//  BitpayPaymentRequest.swift
//  Blockchain
//
//  Created by Will Hay on 8/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct BitpayPaymentRequest: Decodable {
    let memo: String
    let expires: String
    let paymentUrl: String
    let outputs: [Output]
    
    enum CodingKeys: String, CodingKey {
        case memo
        case expires
        case paymentUrl
        case outputs
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        memo = try values.decode(String.self, forKey: .memo)
        expires = try values.decode(String.self, forKey: .expires)
        paymentUrl = try values.decode(String.self, forKey: .paymentUrl)
        outputs = try values.decode([Output].self, forKey: .outputs)
    }
    
    init(memo: String, expires: String, paymentUrl: String, outputs: [Output]) {
        self.memo = memo
        self.expires = expires
        self.paymentUrl = paymentUrl
        self.outputs = outputs
    }
}

struct Output: Decodable {
    let amount: Int
    let address: String
}


class ObjcCompatibleBitpayObject: NSObject {
    @objc var memo: String
    @objc var expires: Date
    @objc var paymentUrl: String
    @objc var amount: Int
    @objc var address: String
    
    init(memo: String, expires: Date, paymentUrl: String, amount: Int, address: String) {
        self.memo = memo
        self.expires = expires
        self.paymentUrl = paymentUrl
        self.amount = amount
        self.address = address
    }
    
}
