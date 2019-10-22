//
//  CollectionTextMatchValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// Generalized version of text matcher, resolves a stream from multiple text sources into a boolean
/// that is `true` if and only if all the values are equal
public final class CollectionTextMatchValidator {
        
    // MARK: - Exposed Properties
    
    /// Streams `true` if there is a match between two field
    public var isValid: Observable<Bool> {
        return hasMatchRelay.asObservable()
    }
    
    // MARK: - Injected Properties
    
    private let collection: [TextSource]
    
    // MARK: - Accessors
    
    private let hasMatchRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(_ collection: TextSource..., options: Options = []) {
        self.collection = collection
        Observable
            .combineLatest(collection.map { $0.valueRelay })
            .map { array -> Bool in
                if array.areAllElementsEqual {
                    return true
                // If there is an empty string in the array and it should be validated
                } else if array.containsEmpty {
                    return !options.contains(.validateEmpty)
                } else {
                    return false
                }
            }
            .bind(to: hasMatchRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Validation Options

extension CollectionTextMatchValidator {
    
    /// Options according to which the text streams are validated
    public struct Options: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
        
        /// Validate all even though one of the text sources is empty
        public static let validateEmpty = Options(rawValue: 1 << 0)
    }
}
