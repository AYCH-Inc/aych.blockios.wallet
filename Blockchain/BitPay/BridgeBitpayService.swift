//
//  BridgeBitpayService.swift
//  Blockchain
//
//  Created by Will Hay on 7/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

// TODO: Remove this layer once the send screens are migrated to Swift
/// Bridging layer for Swift-ObjC, since ObjC isn't compatible with RxSwift
@objc
class BridgeBitpayService: NSObject {
    
    // MARK: - Properties
    
    private let bitpayService: BitpayServiceProtocol
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(bitpayService: BitpayServiceProtocol = BitpayService()) {
        self.bitpayService = bitpayService
        super.init()
    }
    
    // TODO: remove this - temporary solution because of ObjC compatibility
    override init() {
        self.bitpayService = BitpayService()
        super.init()
    }
    
    @objc func bitpayPaymentRequest(invoiceID: String, assetType: LegacyAssetType, completion: @escaping (ObjcCompatibleBitpayObject?, Error?) -> Void) {
        // TICKET: IOS-2498 - Support BCH
        let currency: CryptoCurrency = assetType == .bitcoin ? .bitcoin : .bitcoin
        bitpayService.bitpayPaymentRequest(
            invoiceID: invoiceID,
            currency: currency
            ).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { bitpayModel in
                completion(bitpayModel, nil)
            }, onError: { error in
                completion(nil, error)
            })
            .disposed(by: disposeBag)
    }
    
    // TICKET: IOS-2498 - Support BCH
    @objc func verifyAndPostSignedTransaction(
        invoiceID: String,
        assetType: LegacyAssetType,
        transactionHex: String,
        transactionSize: String,
        completion: @escaping (String?, Error?) -> Void) {
        guard let size = Int(transactionSize) else {
            completion(nil, NetworkError.default)
            return
        }
        let currency: CryptoCurrency = assetType == .bitcoin ? .bitcoin : .bitcoin
        bitpayService.verifySignedTransaction(
            invoiceID: invoiceID,
            currency: currency,
            transactionHex: transactionHex,
            transactionSize: size
        )
            .flatMap(weak: self, { (self, memo) -> Single<BitPayMemo> in
                return self.bitpayService.postPayment(
                    invoiceID: invoiceID,
                    currency: currency,
                    transactionHex: transactionHex,
                    transactionSize: size
                )
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { memo in
                completion(memo.memo, nil)
            }, onError: { error in
                completion(nil, error)
            })
            .disposed(by: disposeBag)
    }
}
