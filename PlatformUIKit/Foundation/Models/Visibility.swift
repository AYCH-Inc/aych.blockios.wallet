//
//  Visibility.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// We used `Visibility` for hiding and showing
/// specific views. It's easier to read
public enum Visibility: Int {
    case hidden
    case visible
    
    public var defaultAlpha: CGFloat {
        switch self {
        case .hidden: return 0
        case .visible: return 1
        }
    }
    
    public var isHidden: Bool {
        return self == .hidden ? true : false
    }
}
