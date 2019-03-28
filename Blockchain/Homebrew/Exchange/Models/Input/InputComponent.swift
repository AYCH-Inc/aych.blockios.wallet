//
//  InputComponent.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `InputComponent` represents a user entry when they select a value on the
/// number pad. Generally you should infer what the entry is based on the `type`.
/// You can use view models such as `ExchangeInputViewModel` to build what the user
/// is inputting.
struct InputComponent: Equatable {
    let entry: InputComponentEntry
    let type: InputComponentType
    
    init(entry: InputComponentEntry, type: InputComponentType) {
        self.entry = entry
        self.type = type
    }
}

extension InputComponent {
    
    /// Static helpers for easily checking if the entry `contains` any of the below
    /// input values. 
    static let zero = InputComponent(entry: .zero("0"), type: .whole)
    static let tenthsZero = InputComponent(entry: .zero("0"), type: .tenths)
    static let hundredthsZero = InputComponent(entry: .zero("0"), type: .hundredths)
    static let fractionalZero = InputComponent(entry: .zero("0"), type: .fractional)
    static let delimiter = InputComponent(entry: .nonzero(Locale.current.decimalSeparator ?? "."), type: .delimiter)
    
    var value: String {
        switch entry {
        case .nonzero(let value):
            return value
        case .zero(let value):
            return value
        }
    }
}

/// We may want to differentiate from zero and nonzero entries, and this
/// is much easier than validating the string.
enum InputComponentEntry {
    case nonzero(String)
    case zero(String)
}

extension InputComponentEntry: Equatable {
    static func ==(lhs: InputComponentEntry, rhs: InputComponentEntry) -> Bool {
        switch (lhs, rhs) {
        case (.nonzero(let left), .nonzero(let right)):
            return left == right
        case (.zero(let left), .zero(let right)):
            return left == right
        default:
            return false
        }
    }
}

extension Array where Element == InputComponent {
    
    var canDrop: Bool {
        if let model = first, count == 1 {
            return model.value != "0"
        }
        return count > 1
    }
    
    func drop() -> [Element] {
        switch count {
        case 0:
            return self
        case 1:
            if let model = first {
                switch model.value {
                case "0":
                    return self
                default:
                    return [.zero]
                }
            }
        default:
            break
        }
        return Array(self.dropLast())
    }
}
