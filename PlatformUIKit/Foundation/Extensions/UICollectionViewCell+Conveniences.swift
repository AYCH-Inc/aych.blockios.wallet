//
//  UICollectionViewCell+Conveniences.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    /// This is math that we will perform all the time when
    /// calculating item widths for nested collectionViews (e.g. ContainerCells).
    class func itemWidthFor(_ width: CGFloat, layoutAttributes: LayoutAttributes, columns: CGFloat) -> CGFloat {
        let horizontalInsets = layoutAttributes.sectionInsets.left + layoutAttributes.sectionInsets.right
        let totalItemSpacing = (columns - 1) * layoutAttributes.minimumInterItemSpacing
        let availableWidth = width - horizontalInsets - totalItemSpacing
        
        return floor(availableWidth / columns)
    }
}
