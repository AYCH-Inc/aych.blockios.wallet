//
//  BitpayPayProService.swift
//  Blockchain
//
//  Created by Will Hay on 7/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

final class BitpayService: BitpayServiceProtocol {
    
    // MARK: Models
    
    private struct Payment: Encodable {
        let chain: String
        let transactions: [Transaction]
        
        struct Transaction: Encodable {
            let tx: String
            let weightedSize: Int
        }
        
        init(chain: String, transactions: [Transaction]) {
            self.chain = chain
            self.transactions = transactions
        }
    }

    private let recorder: AnalyticsEventRecording
    private let network: NetworkCommunicatorAPI
    private let bitpayUrl: String = "https://bitpay.com/"
    private let invoicePath: String = "i/"
    
    /// A recorder that marks the Bitpay announcement removed once the URI was used
    private let announcementRecorder: AnnouncementRecorder
    
    // MARK: Init
    
    init(recorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         network: NetworkCommunicatorAPI = NetworkCommunicator.shared,
         cacheSuite: CacheSuite = UserDefaults.standard) {
        self.recorder = recorder
        self.network = network
        self.announcementRecorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
    }
    
    // MARK: BitpayServiceProtocol
    
    func bitpayPaymentRequest(invoiceID: String, currency: CryptoCurrency) -> Single<ObjcCompatibleBitpayObject> {
        return buildBitpayPaymentRequest(invoiceID: invoiceID, currency: currency).map {
            let expiresLocalTime = self.UTCToLocal(date: $0.expires)
            return ObjcCompatibleBitpayObject(
                memo: $0.memo,
                expires: expiresLocalTime,
                paymentUrl: $0.paymentUrl,
                amount: $0.outputs[0].amount,
                address: $0.outputs[0].address
            )
        }
    }
    
    func verifySignedTransaction(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo> {
        let transaction = Payment.Transaction(tx: transactionHex, weightedSize: transactionSize)
        let signed = Payment(chain: currency.rawValue, transactions: [transaction])
        let headers = ["x-paypro-version": "2",
                       HttpHeaderField.contentType: "application/payment-verification",
                       "BP_PARTNER": "Blockchain",
                       "BP_PARTNER_VERSION": "V6.28.0"]
        
        guard let url = URL(string: bitpayUrl + invoicePath + invoiceID) else {
            return Single.error(NetworkError.generic(message: nil))
        }
        
        let request = NetworkRequest(endpoint: url, method: .post, body: try? JSONEncoder().encode(signed), headers: headers)
        return network.perform(request: request)
    }
    
    func postPayment(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo> {
        let transaction = Payment.Transaction(tx: transactionHex, weightedSize: transactionSize)
        let signed = Payment(chain: currency.rawValue, transactions: [transaction])
        let headers = ["x-paypro-version": "2",
                       HttpHeaderField.contentType: "application/payment",
                       "BP_PARTNER": "Blockchain",
                       "BP_PARTNER_VERSION": "V6.28.0"]
        guard let url = URL(string: bitpayUrl + invoicePath + invoiceID) else {
            return Single.error(NetworkError.generic(message: nil))
        }
        let request = NetworkRequest(endpoint: url, method: .post, body: try? JSONEncoder().encode(signed), headers: headers)
        return network.perform(request: request).do(onSuccess: { [weak self] _ in
            self?.recorder.record(event: AnalyticsEvents.Bitpay.bitpayPaymentSuccess)
        }, onError: { [weak self] error in
            self?.recorder.record(event: AnalyticsEvents.Bitpay.bitpayPaymentFailure(error: error))
        })
    }
    
    // MARK: Private Functions
    
    private func buildBitpayPaymentRequest(invoiceID: String, currency: CryptoCurrency) -> Single<BitpayPaymentRequest> {
        let payload = ["chain": currency.rawValue]
        let headers = ["x-paypro-version": "2",
                       HttpHeaderField.contentType: "application/payment-request",
                       "BP_PARTNER": "Blockchain",
                       "BP_PARTNER_VERSION": "V6.28.0"]
        guard let url = URL(string: bitpayUrl + invoicePath + invoiceID) else {
            return Single.error(NetworkError.generic(message: nil))
        }
        let request = NetworkRequest(endpoint: url, method: .post, body: try? JSONEncoder().encode(payload), headers: headers)
        return self.network.perform(request: request)
    }
    
    private func UTCToLocal(date:String) -> Date {
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
        
        return networkReq
            .map {
                let expiresLocalTime = self.UTCToLocal(date: $0.expires)
                return ObjcCompatibleBitpayObject(memo: $0.memo, expires: expiresLocalTime, paymentUrl: $0.paymentUrl, amount: $0.outputs[0].amount, address: $0.outputs[0].address)
            }
            .do(onSuccess: { [weak self] _ in
                self?.announcementRecorder[.bitpay].markRemoved(category: .oneTime)
            })
    }
}
