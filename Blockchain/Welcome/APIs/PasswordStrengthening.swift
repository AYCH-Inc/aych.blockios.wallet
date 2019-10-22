//
//  PasswordStrengthening.swift
//  Blockchain
//
//  Created by AlexM on 10/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

enum PasswordStength {
    case low
    case regular
    case normal
    case strong
    
    init(value: Int) {
        switch value {
        case 0...25:
            self = .low
        case 25...50:
            self = .regular
        case 50...75:
            self = .normal
        default:
            self = .strong
        }
    }
}

protocol PasswordStrengthening {
    func strengthOfPassword(_ password: String) -> Single<PasswordStength>
}

extension Wallet: PasswordStrengthening {
    func strengthOfPassword(_ password: String) -> Single<PasswordStength> {
        let value = getStrengthForPassword(password)
        let strength = PasswordStength(value: Int(value))
        return Single.just(strength)
    }
}
