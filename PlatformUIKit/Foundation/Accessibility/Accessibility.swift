//
//  Accessibility.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Accessibility construct that to support multiple accessibility assignments at once
public struct Accessibility {
    
    /// A generic value
    public enum Value<T> {
        
        /// Contains a value of type `T`
        case value(T)
        
        /// Doesn't contain any value
        case none
        
        var rawValue: T? {
            switch self {
            case .value(let rawValue):
                return rawValue
            case .none:
                return nil
            }
        }
    }
    
    /// `.none` represents an inaccessible element
    public static var none: Accessibility {
        return Accessibility(isAccessible: false)
    }
    
    /// The accessibility identifier
    public let id: Value<String>
    
    /// The accessibility label
    public let label: Value<String>
    
    /// The accessibility hint
    public let hint: Value<String>
    
    /// The accessibility traits of the view
    public let traits: Value<UIAccessibilityTraits>
    
    /// Is accessibility element
    public let isAccessible: Bool
    
    /// Initializes inner properties by defaulting all parameters to `.none`.
    public init(id: Value<String> = .none,
                label: Value<String> = .none,
                hint: Value<String> = .none,
                traits: Value<UIAccessibilityTraits> = .none,
                isAccessible: Bool = true) {
        self.id = id
        self.label = label
        self.hint = hint
        self.traits = traits
        self.isAccessible = isAccessible
    }
}

/// MARK: - Conveniences

extension Accessibility {
    public static func id(_ rawValue: String) -> Accessibility {
        return .init(id: .value(rawValue))
    }
}
