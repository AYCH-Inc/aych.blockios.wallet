//
//  BitpayPayProService.swift
//  Blockchain
//
//  Created by Will Hay on 7/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

final class BitpayService: BitpayServiceProtocol {
    
    private let network: NetworkCommunicatorAPI
    private let bitpayUrl: String = "https://bitpay.com/"
    private let invoicePath: String = "i/"
    
    init(network: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.network = network
    }
    
    func UTCToLocal(date:String) -> Date {
        let dateFormatter = DateFormatter.sessionDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        
        let dateLocalString = dateFormatter.string(from: dt!)
        
        return dateFormatter.date(from: dateLocalString)!
    }
    
    func getRawPaymentRequest(for invoiceId: String) -> Single<ObjcCompatibleBitpayObject> {
        let headers = [HttpHeaderField.accept: "application/payment-request",
                       HttpHeaderField.contentType: HttpHeaderValue.json]
        
        guard let url = URL(string: bitpayUrl + invoicePath + invoiceId) else {
            return Single.error(NetworkError.generic(message: nil))
        }
        
        let request = NetworkRequest(endpoint:url, method: .get, headers: headers, contentType: .json)
        let networkReq: Single<BitpayPaymentRequest> = self.network.perform(request: request)
        
        return networkReq.map {
                let expiresLocalTime = self.UTCToLocal(date: $0.expires)
                
                return ObjcCompatibleBitpayObject(memo: $0.memo, expires: expiresLocalTime, paymentUrl: $0.paymentUrl, amount: $0.outputs[0].amount, address: $0.outputs[0].address)
                
            }
    }
}
