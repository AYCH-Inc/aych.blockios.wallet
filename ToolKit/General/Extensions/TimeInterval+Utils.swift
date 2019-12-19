//
//  TimeInterval+Utils.swift
//  PlatformKit
//
//  Created by Daniel Huri on 29/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    /// Represents a day in second units
    public static let day: TimeInterval = 60 * 60 * 24
    
    /// Represents a week in second units
    public static let week: TimeInterval = day * 7
}
