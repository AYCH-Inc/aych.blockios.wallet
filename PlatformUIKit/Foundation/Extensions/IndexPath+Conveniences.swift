//
//  IndexPath+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension IndexPath {
    public static var firstRowInFirstSection: IndexPath {
        return IndexPath(row: 0, section: 0)
    }
}
