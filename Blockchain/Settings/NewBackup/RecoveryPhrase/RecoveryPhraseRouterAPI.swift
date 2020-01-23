//
//  RecoveryPhraseRouterAPI.swift
//  Blockchain
//
//  Created by AlexM on 1/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

protocol RecoveryPhraseRouterAPI: class {
    func verify(mnemonic: [String])
}
