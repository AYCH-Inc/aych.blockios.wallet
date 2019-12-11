//
//  PinInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

protocol PinInteracting: class {
    var hasLogoutAttempted: Bool { get set }
    func create(using payload: PinPayload) -> Completable
    func validate(using payload: PinPayload) -> Single<String>
    func password(from pinDecryptionKey: String) -> Single<String>
    func persist(pin: Pin)
}
