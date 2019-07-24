//
//  CGRect+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 7/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension CGRect {
    /// Returns the smaller of two frames, preserving the origin. 
    func min(_ frame: CGRect) -> CGRect {
        if width > frame.width || width > frame.height {
            return .init(origin: origin, size: frame.size)
        } else {
            return self
        }
    }
}
