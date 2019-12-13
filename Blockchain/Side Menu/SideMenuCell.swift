//
//  SideMenuCell.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class SideMenuCell: UITableViewCell {
    
    fileprivate static let newContainerViewTrailingPadding: CGFloat = 16.0
    
    /// You must take into accoun the `peekAmount` of `ECSlidingViewController`
    /// otherwise the `newContainer` will not be visible.
    lazy var peekPadding: CGFloat = {
        let controller = AppCoordinator.shared.slidingViewController
        return controller?.anchorRightPeekAmount ?? 0
    }()

    static let defaultHeight: CGFloat = 54

    @IBOutlet var passthroughView: PassthroughView!
    @IBOutlet fileprivate var title: UILabel!
    @IBOutlet fileprivate var icon: UIImageView!
    @IBOutlet fileprivate var newContainerView: UIView!
    @IBOutlet fileprivate var newLabel: UILabel!
    @IBOutlet fileprivate var newContainerTrailingConstraint: NSLayoutConstraint!
    
    var item: SideMenuItem? {
        didSet {
            title.text = item?.title
            icon.image = item?.image.withRenderingMode(.alwaysTemplate)
            guard let value = item else {
                newContainerView.alpha = 0.0
                return
            }
            newContainerView.alpha = value.isNew ? 1.0 : 0.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        title.textColor = #colorLiteral(red: 0.51, green: 0.55, blue: 0.62, alpha: 1)
        title.highlightedTextColor = #colorLiteral(red: 0.51, green: 0.55, blue: 0.62, alpha: 1)
        icon.tintColor = #colorLiteral(red: 0.51, green: 0.55, blue: 0.62, alpha: 1)
        newContainerView.layer.cornerRadius = 4.0
        newLabel.text = LocalizationConstants.SideMenu.new
        let padding = SideMenuCell.newContainerViewTrailingPadding
        guard newContainerTrailingConstraint.constant != padding + peekPadding else { return }
        newContainerTrailingConstraint.constant = padding + peekPadding
        setNeedsLayout()
        layoutIfNeeded()
    }
}
