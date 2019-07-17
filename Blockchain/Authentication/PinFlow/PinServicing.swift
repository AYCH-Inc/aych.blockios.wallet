//
//  PinServicing.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

typealias PinServicing = PinCreationServicing & PinValidationServicing

/// Serves PIN creation domain
protocol PinCreationServicing {
    func create(pinPayload: PinPayload) -> Single<PinStoreResponse>
}

/// Serves PIN validation domain
protocol PinValidationServicing {
    /// Validate PIN
    func validate(pinPayload: PinPayload) -> Single<PinStoreResponse>
}
