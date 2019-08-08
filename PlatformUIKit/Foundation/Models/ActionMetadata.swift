//
//  ActionMetadata.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol ActionPayload { }

/// This may be renamed but the idea here is that where `AlertActions` or `BottomSheetActions` are built
/// you can define different things that should happen when the action is selected like
/// presenting a URL, executing a block, or receiving any `ActionPayload` if you
/// need some custom behavior.
public enum ActionMetadata {
    case url(URL)
    case block(() -> Void)
    case pop
    case dismiss
    case payload(ActionPayload)
    
    /// Returns the associated block closure (if any)
    public var block: (() -> Void)? {
        switch self {
        case .block(let block):
            return block
        default:
            return nil
        }
    }
}
