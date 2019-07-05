//
//  ContainerModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum ContainerModel: Equatable {
    case standard(StandardContainerModel)
    case paginated(PaginatedContainerModel)
}

extension ContainerModel {
    public static func ==(lhs: ContainerModel, rhs: ContainerModel) -> Bool {
        switch (lhs, rhs) {
        case (standard(let left), .standard(let right)):
            return left == right
        case (.paginated(let left), .paginated(let right)):
            return left == right
        default:
            return false
        }
    }
}
