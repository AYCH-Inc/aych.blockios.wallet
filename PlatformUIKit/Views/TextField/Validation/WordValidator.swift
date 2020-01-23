//
//  WordValidator.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// Regex validator. Receives a `TextRegex` and validates the value against it.
final class WordValidator: TextValidating {
    
    // MARK: - TextValidating Properties
    
    let valueRelay = BehaviorRelay<String>(value: "")
    var isValid: Observable<Bool> {
        return isValidRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let isValidRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(word: String) {
        valueRelay
            .map { $0.lowercased() == word.lowercased() }
            .bind(to: isValidRelay)
            .disposed(by: disposeBag)
    }
}

