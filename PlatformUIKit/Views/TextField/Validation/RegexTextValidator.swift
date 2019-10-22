//
//  RegexTextValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// Regex validator. Receives a `TextRegex` and validates the value against it.
final class RegexTextValidator: TextValidating {
    
    // MARK: - TextValidating Properties
    
    let valueRelay = BehaviorRelay<String>(value: "")
    var isValid: Observable<Bool> {
        return isValidRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let isValidRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(regex: TextRegex) {
        valueRelay
            .map { value in
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
                return predicate.evaluate(with: value)
            }
            .bind(to: isValidRelay)
            .disposed(by: disposeBag)
    }
}
