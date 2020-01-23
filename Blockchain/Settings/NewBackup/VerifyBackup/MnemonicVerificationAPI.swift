//
//  MnemonicVerificationAPI.swift
//  Blockchain
//
//  Created by AlexM on 1/21/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

// TICKET: IOS-2848 - Move Mnemonic Verification Logic from JS to Swift
protocol MnemonicVerificationAPI {
    var isVerified: Observable<Bool> { get }
    func verifyMnemonicAndSync() -> Completable
}
