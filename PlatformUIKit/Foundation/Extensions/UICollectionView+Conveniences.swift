//
//  UICollectionView+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension UICollectionView {
    
    func register<CellType: UICollectionViewCell>(_ cellType: CellType.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.objectName)
    }
    
    func registerNibCell(_ name: String, bundle: Bundle = .main) {
        register(UINib(nibName: name, bundle: bundle), forCellWithReuseIdentifier: name)
    }
    
    func registerNibCells(_ names: String..., bundle: Bundle = .main) {
        for name in names {
            register(UINib(nibName: name, bundle: bundle), forCellWithReuseIdentifier: name)
        }
    }
    
    func dequeue<CellType: UICollectionViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        return dequeueReusableCell(withReuseIdentifier: type.objectName, for: indexPath) as! CellType
    }
}
