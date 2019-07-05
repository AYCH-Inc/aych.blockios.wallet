//
//  PaginatedContainerModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `PaginatedContainerModel` is to be used with `PaginatedContainerCell`. You
/// use it by supply a `ContainerModel` of type `.paginated(PaginatedContainerModel)`.
/// Extensions on `ContainerModel` will infer what cell is associated with type `.paginated`
public struct PaginatedContainerModel: Equatable {
    public let cells: [CellModel]
    public let title: String?
    public let pageControlColor: UIColor?
    public let currentPageTintColor: UIColor?
    public let backgroundColor: UIColor?
    
    public init(
        cells: [CellModel],
        pageControlColor: UIColor? = nil,
        currentPageTintColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        title: String? = nil
        ) {
        self.cells = cells
        self.pageControlColor = pageControlColor
        self.currentPageTintColor = currentPageTintColor
        self.backgroundColor = backgroundColor
        self.title = title
    }
}

extension PaginatedContainerModel {
    
    public var layout: ContainerLayout {
        return ContainerLayout(type: .horizontal, columns: 1.0)
    }
    
    public static func ==(lhs: PaginatedContainerModel, rhs: PaginatedContainerModel) -> Bool {
        return lhs.cells == rhs.cells &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.title == rhs.title
    }
}

extension PaginatedContainerModel {
    public static let demo1: PaginatedContainerModel = PaginatedContainerModel(
        cells: [.transactionDetail(.demo1),
                .transactionDetail(.demo2)],
        backgroundColor: .lightGray,
        title: "Insert Title"
    )
    
    public static let demo2: PaginatedContainerModel = PaginatedContainerModel(
        cells: [.transactionDetail(.demo2),
                .transactionDetail(.demo1),
                .transactionDetail(.demo2),
                .transactionDetail(.demo1)],
        backgroundColor: .gray,
        title: "Insert Title"
    )
}
