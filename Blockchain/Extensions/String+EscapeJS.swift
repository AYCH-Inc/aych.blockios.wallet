//
//  String+EscapeJS.swift
//  Blockchain
//
//  Created by Maurice A. on 5/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

@objc extension NSString {
    func escapedForJS() -> String {
        return (self as String).escapedForJS()
    }
}
