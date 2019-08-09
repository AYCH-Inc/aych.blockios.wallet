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
    
    @objc func getRawPaymentRequest(invoiceId: String,
                                    completion: @escaping (ObjcCompatibleBitpayObject?) -> Void) {
        bitpayService.getRawPaymentRequest(for: invoiceId)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { result in
                completion(result)
            }, onError: { error in
                Logger.shared.error(error)
                completion(nil)
            })
            .disposed(by: disposeBag)
    }
}
