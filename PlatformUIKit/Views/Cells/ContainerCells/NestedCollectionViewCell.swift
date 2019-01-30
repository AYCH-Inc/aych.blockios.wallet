//
//  NestedCollectionViewCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class NestedCollectionViewCell: BaseCell {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!
    
    public var needsReloadOnNextLayout = false
}
