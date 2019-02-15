//
//  PricePreviewCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class PricePreviewCell: BaseCell {
    
    fileprivate static let horizontalPadding: CGFloat = 32.0
    fileprivate static let topToHeadlinePadding: CGFloat = 32.0
    fileprivate static let headlineToPricePadding: CGFloat = 4.0
    fileprivate static let priceToButtonPadding: CGFloat = 16.0
    fileprivate static let bottomPadding: CGFloat = 32.0
    fileprivate static let buttonHeight: CGFloat = 31.0
    
    @IBOutlet fileprivate var headline: UILabel!
    @IBOutlet fileprivate var price: UILabel!
    @IBOutlet fileprivate var seeChartsButton: UIButton!
    
    fileprivate var model: PricePreview?
    
    // MARK: Overrides
    
    public override func configure(_ model: CellModel) {
        guard case let .pricePreview(payload) = model else { return }
        self.model = payload
        headline.text = payload.title
        price.text = payload.value.toDisplayString()
        seeChartsButton.setImage(payload.logo, for: .normal)
    }
    
    public override class func heightForProposedWidth(_ width: CGFloat, model: CellModel) -> CGFloat {
        guard case let .pricePreview(payload) = model else { return 0.0 }
        let attributedTitle = NSAttributedString(
            string: payload.title,
            attributes: [.font: headlineFont()]
        )
        let attributedPrice = NSAttributedString(
            string: payload.value.toDisplayString(),
            attributes: [.font: priceFont()]
        )
        let titleHeight = attributedTitle.heightForWidth(width: width - horizontalPadding)
        let priceHeight = attributedPrice.heightForWidth(width: width - horizontalPadding)
        return titleHeight +
            priceHeight +
            topToHeadlinePadding +
            headlineToPricePadding +
            priceToButtonPadding +
            bottomPadding +
            buttonHeight
    }
    
    // MARK: Private Class Functions
    
    fileprivate static func headlineFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(14.0))
        return font.result
    }
    
    fileprivate static func priceFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(24.0))
        return font.result
    }
    
    // MARK: Actions
    
    @IBAction func seeChartsTapped(_ sender: UIButton) {
        model?.action()
    }
    
}
