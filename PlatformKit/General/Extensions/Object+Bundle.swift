//
//  Object+Bundle.swift
//  PlatformKit
//
//  Created by Daniel Huri on 11/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension NSObject {
    
    /// Returns the object's class bundle. Particularly useful in registering resources
    /// that do not belong to the `Bundle.main`
    public var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    /// Returns the object's class bundle. Particularly useful in registering resources
    /// that do not belong to the `Bundle.main`
    public class var bundle: Bundle {
        return Bundle(for: self)
    }
}
