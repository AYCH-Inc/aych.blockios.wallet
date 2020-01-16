//
//  MockBitpayService.swift
//  Blockchain
//
//  Created by Will Hay on 8/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

@testable import Blockchain

class MockBitpayService: BitpayServiceProtocol {
    
    func verifySignedTransaction(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo> {
        return Single.just(BitPayMemo(memo: "Test"))
    }
    
    func postPayment(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo> {
        return Single.just(BitPayMemo(memo: "Test"))
    }

    func bitpayPaymentRequest(invoiceID: String, currency: CryptoCurrency) -> Single<ObjcCompatibleBitpayObject> {
        let memo = "Payment request for BitPay invoice " + "\(invoiceID)" + " for merchant Will"
        let paymentUrl = "https://bitpay.com/i/" + "\(invoiceID)"
        let data = Data(
            """
                {
                "memo": "\(memo)",
                "requiredFeeRate": 22.2,
                "expires": "2008-09-15T15:53:00.123Z",
                "paymentId": "PfCwZLxWctSrdgYcnJM8G8",
                "paymentUrl": "\(paymentUrl)",
                "instructions" : [{"outputs": [{"amount":2, "address":"3PRRj3H8WPgZLBaYQNrT5Bdw2Z7n12EXKs"}]}]
                }
                """.utf8)
        do {
            let result = try JSONDecoder().decode(BitpayPaymentRequest.self,
                                                  from: data)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let expiresLocalTime = dateFormatter.date(from: result.expires)!

            return Single.just(
               ObjcCompatibleBitpayObject(
                    memo: result.memo,
                    expires: expiresLocalTime,
                    paymentUrl: result.paymentUrl,
                    amount: result.outputs[0].amount,
                    address: result.outputs[0].address
                )
            )
        } catch {
            return .error(error)
        }
    }

}
