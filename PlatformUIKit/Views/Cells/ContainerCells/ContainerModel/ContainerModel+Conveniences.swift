//
//  ContainerModel+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension ContainerModel {
    
    public func reuseIdentifier() -> String {
        switch self {
        case .standard(let model):
            switch model.layout.type {
            case .horizontal:
                return HorizontalContainerCell.identifier
            case .vertical:
                return VerticalContainerCell.identifier
            }
        case .paginated:
            return PaginatedContainerCell.identifier
        }
    }
    
    public func cellType() -> BaseCell.Type {
        switch self {
        case .standard(let model):
            switch model.layout.type {
            case .horizontal:
                return HorizontalContainerCell.self
            case .vertical:
                return VerticalContainerCell.self
            }
        case .paginated:
            return PaginatedContainerCell.self
        }
    }
    
    public func heightForProposed(width: CGFloat, indexPath: IndexPath) -> CGFloat {
        let height = cellType().heightForProposedWidth(
            width,
            containerModel: self
        )
        return height
    }
    
}
