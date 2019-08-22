//
//  Object+Name.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension NSObject {
    
    /// Returns the object's class name. Particularly useful in saving raw strings usage in code.
    public var objectName: String {
        return String(describing: type(of: self))
    }
    
    /// Returns the object's class name. Particularly useful in saving raw strings usage in code.
    public class var objectName: String {
        return String(describing: self)
    }
}
