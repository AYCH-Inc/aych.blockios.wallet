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
    
    func registerNibCell(_ name: String, bundle: Bundle = .main) {
        register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
    }
    
    func registerNibCells(_ names: String..., bundle: Bundle = .main) {
        for name in names {
            register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
        }
    }
    
    func dequeue<CellType: UITableViewCell>(_ identifier: String, for indexPath: IndexPath) -> CellType {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CellType
    }
}
