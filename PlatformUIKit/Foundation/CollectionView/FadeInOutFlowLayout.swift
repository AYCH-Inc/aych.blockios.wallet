//
//  FadeInOutFlowLayout.swift
//  PlatformUIKit
//
//  Created by AlexM on 7/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class FadeInOutFlowLayout: UICollectionViewFlowLayout {
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        return attributes.compactMap { self.animateAttributes($0) }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    private func animateAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }
        let contentOffset = collectionView.contentOffset
        
        let offset = scrollDirection == .horizontal ? attributes.center.x - contentOffset.x : attributes.center.y - contentOffset.y
        let distance = scrollDirection == .horizontal ? collectionView.frame.width : collectionView.frame.height
        let middleOffset = offset / distance - 0.5
        
        if abs(middleOffset) >= 1 {
            attributes.transform = .identity
            attributes.alpha = 1.0
        } else {
            attributes.alpha = 1.0 - abs(middleOffset)
            let transform = max(1 - abs(middleOffset), 0.95)
            attributes.transform = CGAffineTransform(scaleX: transform, y: transform)
        }
        return attributes
    }
}
