//
//  MnemonicValidator.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

/// Validates the users mnemonic or passphrase entry
final class MnemonicValidator: MnemonicValidating {
    
    // MARK: - TextValidating Properties
    
    public let valueRelay = BehaviorRelay<String>(value: "")
    var isValid: Observable<Bool> {
        return isValidRelay.asObservable()
    }
    
    // MARK: - MnemonicValidating Properties
    
    public var score: Observable<MnemonicValidationScore> {
        return scoreRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let scoreRelay = BehaviorRelay<MnemonicValidationScore>(value: .none)
    private let isValidRelay = BehaviorRelay<Bool>(value: false)
    private let words: Set<String>
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(words: Set<String>, mnemonicLength: Int = 12) {
        self.words = words
        
        valueRelay
            .map(weak: self) { (self, phrase) -> MnemonicValidationScore in
                if phrase.isEmpty {
                    return .none
                }
                
                /// Make an array of the individual words
                let components = phrase.components(separatedBy: .whitespacesAndNewlines).filter { $0.count > 0 }
                
                /// Separate out the words that are duplicates
                let duplicates = Set(components.duplicates ?? [])
                
                /// The total number of duplicates entered
                let duplicatesCount = duplicates.map { dupe in
                    return components.filter { $0 == dupe }.count
                }.reduce(0, +)
                
                /// Make a set for all the individual entries
                let set = Set(phrase.components(separatedBy: .whitespacesAndNewlines)).filter { $0.count > 0 && duplicates.contains($0) == false }
                
                guard set.count > 0 || duplicatesCount > 0 else { return .none }
                
                /// Are all the words entered thus far valid words
                let entriesAreValid = set.isSubset(of: self.words) && Set(duplicates).isSubset(of: self.words)
                if entriesAreValid {
                    /// The total number of individual words entered
                    let total = set.count + duplicatesCount
                    switch total == mnemonicLength {
                    case true:
                        return .complete
                    case false:
                        return .incomplete
                    }
                }
                
                /// Combine the `set` and `duplicates` to form a `Set<String>` of all
                /// words that are not included in the `WordList`
                let difference = (set.union(duplicates)).subtracting(self.words)
                
                /// Find the `NSRange` value for each word or incomplete word that is not
                /// included in the `WordList`
                let ranges = difference.map { delta -> [NSRange] in
                    return phrase.ranges(of: delta)
                }.flatMap { $0 }
                
                return .invalid(ranges)
        }
        .catchErrorJustReturn(.none)
        .bind(to: scoreRelay)
        .disposed(by: disposeBag)
        
        scoreRelay
            .map { $0.isValid }
            .bind(to: isValidRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: Convenience

fileprivate extension String {
    /// A convenience function for getting an array of `NSRange` values
    /// for a particular substring.
    func ranges(of substring: String) -> [NSRange] {
        var ranges: [Range<Index>] = []
        enumerateSubstrings(in: self.startIndex ..< self.endIndex, options: .byWords) { word, value, _, _ in
            if let word = word, word == substring {
                ranges.append(value)
            }
        }
        return ranges.map { NSRange($0, in: self) }
    }
}
