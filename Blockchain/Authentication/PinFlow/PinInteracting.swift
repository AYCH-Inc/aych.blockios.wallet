//
//  PinInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol PinInteracting {
    func create(using payload: PinPayload) -> Completable
    func validate(using payload: PinPayload) -> Single<String>
    func persist(pin: Pin)
}
