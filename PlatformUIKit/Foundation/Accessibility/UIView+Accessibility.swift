//
//  UIView+Accessibility.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// An extension to `UIView` which contains all the accessibility
extension UIView {
    
    /// Represents a `UIView` accessibility.
    /// In case one of `Accessibility`'s properties are `.none`, the value won't be assigned at all
    /// To nullify a value just pass an `empty` value, like this: `value(nil)` for id,
    /// or `value(UIAccessibilityTraits.none)` for traits.
    public var accessibility: Accessibility {
        set {
            if case .value(let id) = newValue.id {
                accessibilityIdentifier = id
            }
            if case .value(let label) = newValue.label {
                accessibilityLabel = label
            }
            if case .value(let hint) = newValue.hint {
                accessibilityHint = hint
            }
            if case .value(let traits) = newValue.traits {
                accessibilityTraits = traits
            }
            isAccessibilityElement = newValue.isAccessible
        }
        get {
            return Accessibility(id: accessibilityIdentifier != nil ? .value(accessibilityIdentifier!) : .none,
                                 label: accessibilityLabel != nil ? .value(accessibilityLabel!) : .none,
                                 hint: accessibilityHint != nil ? .value(accessibilityHint!) : .none,
                                 traits: accessibilityTraits != .none ? .value(accessibilityTraits) : .none,
                                 isAccessible: isAccessibilityElement)
        }
    }
}
