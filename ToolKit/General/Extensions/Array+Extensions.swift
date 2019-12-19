//
//  Array+Extensions.swift
//  PlatformKit
//
//  Created by Jack on 24/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}

// MARK: - Hashable

extension Array where Element: Hashable {
    public var duplicates: Array<Element>? {
        let dictionary = Dictionary(grouping: self, by: { $0 })
        let pairs = dictionary.filter { $1.count > 1 }
        let duplicates = Array(pairs.keys)
        return duplicates.count > 0 ? duplicates : nil
    }
}


// MARK: - Equatable

extension Array where Element: Equatable {
    public var areAllElementsEqual: Bool {
        guard let first = self.first else { return true }
        return !dropFirst().contains { $0 != first }
    }
    
    /// Returns `true` if if all elements are equal to a given value
    public func areAllElements(equal element: Element) -> Bool {
        return !contains { $0 != element }
    }
}

// MARK: - String

extension Array where Element == String {
    public var containsEmpty: Bool {
        return contains("")
    }
}

