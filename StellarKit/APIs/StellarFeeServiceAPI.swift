//
//  StellarFeeServiceAPI.swift
//  StellarKit
//
//  Created by AlexM on 8/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol StellarFeeServiceAPI {
    var fees: Single<StellarTransactionFee> { get }
}
