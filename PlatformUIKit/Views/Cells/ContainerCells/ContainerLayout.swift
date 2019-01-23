//
//  ContainerLayout.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum ContainerType {
    case horizontal
    case vertical
}

public struct ContainerLayout: Equatable {
    public let type: ContainerType
    public let columns: CGFloat
    
    init(type: ContainerType, columns: CGFloat) {
        self.type = type
        self.columns = columns
    }
}

public extension ContainerLayout {
    public static func ==(lhs: ContainerLayout, rhs: ContainerLayout) -> Bool {
        return lhs.type == rhs.type &&
        lhs.columns == rhs.columns
    }
}
