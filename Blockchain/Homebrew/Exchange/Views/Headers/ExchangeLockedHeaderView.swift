//
//  ExchangeLockedHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

class ExchangeLockedHeaderView: ExchangeHeaderView {
    
    // MARK: - Public
    
    var closeTapped: (() -> Void)?
    
    // MARK: - Private Static Properties
    
    static fileprivate let verticalPadding: CGFloat = 52.0
    
    // MARK: - Private IBOutlets
    
    @IBOutlet fileprivate var title: UILabel!
    
    // MARK: Public
    
    override func configure(with model: ExchangeHeader) {
        guard case let .locked(payload) = model else { return }
        title.text = payload.title
    }
    
    override class func heightForProposedWidth(_ width: CGFloat, model: ExchangeHeader) -> CGFloat {
        guard case let .locked(payload) = model else { return 0.0 }
        let attributedTitle = NSAttributedString(
            string: payload.title,
            attributes: [
                NSAttributedString.Key.font: titleFont()
            ]
        )
        
        return attributedTitle.heightForWidth(width: width) + verticalPadding
    }
    
    // MARK: Private Class Functions
    
    fileprivate class func titleFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(20.0))
        return font.result
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        closeTapped?()
    }
}
