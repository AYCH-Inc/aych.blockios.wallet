//
//  ToolKitError.swift
//  ToolKit
//
//  Created by Jack on 18/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum ToolKitError: Error {
    case nullReference(AnyObject.Type)
}
