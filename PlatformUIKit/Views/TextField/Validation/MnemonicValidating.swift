//
//  MnemonicValidating.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/10/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol MnemonicValidating: TextValidating {
    var score: Observable<MnemonicValidationScore> { get }
}
