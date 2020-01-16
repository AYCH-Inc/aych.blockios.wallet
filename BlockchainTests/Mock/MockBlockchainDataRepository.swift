//
//  MockBlockchainDataRepository.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import XCTest

@testable import Blockchain

class MockBlockchainDataRepository: BlockchainDataRepository {

    var mockNabuUser: NabuUser?

    init() {
        super.init()
    }

    override var nabuUser: Observable<NabuUser> {
        if let mock = mockNabuUser {
            return Observable.just(mock)
        }
        return super.nabuUser
    }

    override func fetchNabuUser() -> Single<NabuUser> {
        if let mock = mockNabuUser {
            return Single.just(mock)
        }
        return super.fetchNabuUser()
    }
}
