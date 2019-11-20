//
//  UITableView+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit

public extension UITableView {
    
    // MARK: - Mutating accessors
    
    func insertFirst(with animation: RowAnimation = .automatic) {
        insertRows(at: [.firstRowInFirstSection], with: animation)
    }
    
    func deleteFirst(with animation: RowAnimation = .automatic) {
        deleteRows(at: [.firstRowInFirstSection], with: animation)
    }
    
    // MARK: - Register cell type
    
    func register<CellType: UITableViewCell>(_ cellType: CellType.Type) {
        register(cellType, forCellReuseIdentifier: cellType.objectName)
    }
    
    func register<CellType: UITableViewCell>(_ cellTypes: [CellType.Type]) {
        for type in cellTypes {
            register(type, forCellReuseIdentifier: type.objectName)
        }
    }
    
    // MARK: - Register cell name
    
    func registerNibCell(_ name: String, bundle: Bundle = .main) {
        register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
    }
    
    func registerNibCells(_ names: String..., bundle: Bundle = .main) {
        for name in names {
            register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
        }
    }
    
    // MARK: - Dequeue accessors
    
    func dequeue<CellType: UITableViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        return dequeueReusableCell(withIdentifier: type.objectName, for: indexPath) as! CellType
    }
    
    func dequeue<CellType: UITableViewCell>(_ identifier: String, for indexPath: IndexPath) -> CellType {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CellType
    }
}
