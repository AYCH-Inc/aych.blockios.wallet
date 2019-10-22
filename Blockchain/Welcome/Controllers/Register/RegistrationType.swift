//
//  RegistrationType.swift
//  Blockchain
//
//  Created by AlexM on 10/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `RegistrationType` is passed into the `RegisterWalletScreenPresenter`.
/// A type of `default` is for standard wallet creation/registration.
/// A type of `recovery` is for when the user is providing a mnemonic. 
enum RegistrationType {
    case recovery
    case `default`
}
