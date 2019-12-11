//
//  BiometryProviding.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// A protocol that provides the client with biometry API
public protocol BiometryProviding: class {
    var canAuthenticate: Result<Void, Biometry.EvaluationError> { get }
    var configuredType: Biometry.BiometryType { get }
    var configurationStatus: Biometry.Status { get }
    func authenticate(reason: Biometry.Reason) -> Single<Void>
}
