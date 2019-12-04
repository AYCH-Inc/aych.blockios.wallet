//
//  SelfSizingTableView.swift
//  PlatformUIKit
//
//  Created by AlexM on 11/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// Simple `UITableView` that sizes itself. Handy for if your
/// `UITableView` is in a containerView or a `UIStackView`.
public final class SelfSizingTableView: UITableView {
    
    private let maxHeight = UIScreen.main.bounds.size.height
  
    override public func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(
            width: contentSize.width,
            height: min(contentSize.height, maxHeight)
        )
    }
}
