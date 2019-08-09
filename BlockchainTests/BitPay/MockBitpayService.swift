//
//  MockBitpayService.swift
//  Blockchain
//
//  Created by Will Hay on 8/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class MockBitpayService: BitpayServiceProtocol {

    func getRawPaymentRequest(for invoiceId: String) -> Single<ObjcCompatibleBitpayObject> {
        let memo = "Payment request for BitPay invoice " + "\(invoiceId)" + " for merchant Will"
        let paymentUrl = "https://bitpay.com/i/" + "\(invoiceId)"
        let data = Data(
            """
                {
                "memo": "\(memo)",
                "requiredFeeRate": 22.2,
                "expires": "2008-09-15T15:53:00.123Z",
                "paymentUrl": "\(paymentUrl)",
                "outputs": [{"amount":2, "address":"3PRRj3H8WPgZLBaYQNrT5Bdw2Z7n12EXKs"}]
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
