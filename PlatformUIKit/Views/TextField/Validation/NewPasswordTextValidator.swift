//
//  NewPasswordTextValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import zxcvbn_ios

/// Password text validator
final class NewPasswordTextValidator: NewPasswordValidating {
    
    // MARK: - TextValidating Properties
    
    public let valueRelay = BehaviorRelay<String>(value: "")
    
    public var isValid: Observable<Bool> {
        return isValidRelay.asObservable()
    }
    
    // MARK: - NewPasswordValidating Properties
    
    public var score: Observable<PasswordValidationScore> {
        return scoreRelay.asObservable()
    }
        
    // MARK: - Private Properties
    
    private let scoreRelay = BehaviorRelay<PasswordValidationScore>(value: .weak)
    private let isValidRelay = BehaviorRelay<Bool>(value: false)
    private let validator = DBZxcvbn()
    private let disposeBag = DisposeBag()

    init() {
        valueRelay
            .map(weak: self) { (self, password) -> (DBResult?, String) in
                (self.validator.passwordStrength(password), password)
            }
            .map { (result: DBResult?, password) -> PasswordValidationScore in
                guard let result = result else { return .none }
                return PasswordValidationScore(
                    zxcvbnScore: result.score,
                    password: password
                )
            }
            // Ending up in an error state is fine (probably object deallocated)
            .catchErrorJustReturn(.weak)
            .bind(to: scoreRelay)
            .disposed(by: disposeBag)
        
        scoreRelay
            .map { $0.isValid }
            .bind(to: isValidRelay)
            .disposed(by: disposeBag)
    }
}
