//
//  StandardContainerModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct StandardContainerModel: Equatable {
    public let layout: ContainerLayout
    public let cells: [CellModel]
    public let title: String?
    public let backgroundColor: UIColor?
    
    public init(
        layout: ContainerLayout,
        cells: [CellModel],
        backgroundColor: UIColor? = nil,
        title: String? = nil
        ) {
        self.layout = layout
        self.cells = cells
        self.backgroundColor = backgroundColor
        self.title = title
    }
}

public extension StandardContainerModel {
    public static func ==(lhs: StandardContainerModel, rhs: StandardContainerModel) -> Bool {
        return lhs.layout == rhs.layout &&
        lhs.cells == rhs.cells &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.title == rhs.title
    }
}

public extension StandardContainerModel {
    public static let demo1: StandardContainerModel = StandardContainerModel(
        layout: ContainerLayout(type: .vertical, columns: 1.0),
        cells: [.transactionDetail(.demo1),
                .transactionDetail(.demo2)],
        backgroundColor: .lightGray,
        title: "Insert Title"
    )
    
    public static let demo2: StandardContainerModel = StandardContainerModel(
        layout: ContainerLayout(type: .vertical, columns: 1.0),
        cells: [.transactionDetail(.demo2),
                .transactionDetail(.demo1),
                .transactionDetail(.demo2),
                .transactionDetail(.demo1)],
        backgroundColor: .gray,
        title: nil
    )
}
