//
//  AlwaysValidValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// A validato
final class AlwaysValidValidator: TextValidating {
    
    // MARK: - TextValidating Properties
    let valueRelay = BehaviorRelay<String>(value: "")
    var isValid: Observable<Bool> {
        return .just(true)
    }
}

