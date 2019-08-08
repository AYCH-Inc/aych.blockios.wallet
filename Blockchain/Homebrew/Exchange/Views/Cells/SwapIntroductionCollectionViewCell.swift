//
//  SwapIntroductionCollectionViewCell.swift
//  Blockchain
//
//  Created by AlexM on 7/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class SwapIntroductionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var thumbnail: UIImageView!
    @IBOutlet private var headline: UILabel!
    @IBOutlet private var subtitle: UILabel!
    
    func apply(image: UIImage, title: String, subtitle: String) {
        thumbnail.image = image
        headline.text = title
        self.subtitle.text = subtitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
    }
}
