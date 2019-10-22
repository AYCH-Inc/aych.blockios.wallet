//
//  NewPasswordValidating.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol NewPasswordValidating: TextValidating {
    var score: Observable<PasswordValidationScore> { get }
}
