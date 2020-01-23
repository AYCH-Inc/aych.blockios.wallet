//
//  ValidationTextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Localization

/// A view model that represents a password text field
public final class ValidationTextFieldViewModel: TextFieldViewModel {
    
    // MARK: - Properties
    
    /// Visibility of the accessoryView
    var accessoryVisibility: Driver<Visibility> {
        return visibilityRelay
            .asDriver()
            .distinctUntilChanged()
    }
        
    private let visibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let disposeBag =  DisposeBag()
    
    // MARK: - Setup
    
    public override init(with type: TextFieldType,
                validator: TextValidating,
                textMatcher: CollectionTextMatchValidator? = nil) {
        super.init(with: type, validator: validator, textMatcher: textMatcher)
        
    Observable.combineLatest(self.validator.isValid, self.validator.valueRelay)
            .map {
                guard $0.1.isEmpty == false else { return .hidden }
                return $0.0 ? .hidden : .visible
            }
            .bind(to: visibilityRelay)
            .disposed(by: disposeBag)
    }
}

