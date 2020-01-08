//
//  ExchangeDetailHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
import PlatformUIKit

class ExchangeDetailHeaderView: ExchangeHeaderView {
    
    // MARK: Private Static Properties
    
    fileprivate static let verticalPadding: CGFloat = 16.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var headerTitle: UILabel!
    
    // MARK: Public Functions
    
    override func configure(with model: ExchangeHeader) {
        guard case let .detail(payload) = model else { return }
        headerTitle.text = payload.title
        backgroundColor = payload.backgroundColor
    }
    
    override class func heightForProposedWidth(_ width: CGFloat, model: ExchangeHeader) -> CGFloat {
        guard case let .detail(payload) = model else { return 0.0 }
        let attributedTitle = NSAttributedString(
            string: payload.title,
            attributes: [.font: titleFont()]
        )
        return attributedTitle.heightForWidth(width: width) + verticalPadding + verticalPadding
    }
    
    // MARK: Private Class Functions
    
    fileprivate class func titleFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(32.0))
        return font.result
    }
}

struct ExchangeDetailHeaderModel {
    let title: String
    let backgroundColor: UIColor
    
    init(title: String, backgroundColor: UIColor = .brandPrimary) {
        self.title = title
        self.backgroundColor = backgroundColor
    }
}

extension ExchangeDetailHeaderModel {
    static let locked: ExchangeDetailHeaderModel = ExchangeDetailHeaderModel(
        title: LocalizationConstants.Swap.exchangeLocked
    )
}
