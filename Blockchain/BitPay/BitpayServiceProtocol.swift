//
//  BitpayServiceProtocol.swift
//  Blockchain
//
//  Created by Will Hay on 7/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol BitpayServiceProtocol {
    
    func getRawPaymentRequest(for invoiceId: String) -> Single<ObjcCompatibleBitpayObject>
}
