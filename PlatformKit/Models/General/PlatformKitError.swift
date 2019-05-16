//
//  PlatformKitError.swift
//  PlatformKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum PlatformKitError: Error {
    case nullReference(AnyObject.Type)
}
