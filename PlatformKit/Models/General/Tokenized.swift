//
//  Tokenized.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Describes an object with an identifier that can be used to identify it as unique.
 */
public protocol Tokenized {
    /**
     A unique identifier.
     */
    var token: String { get }
}
