//
//  UIView+Nib.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit

/// Convenience extension that enables initialization of a `UIView` from inside the view itself.
/// The nib is initialized as `contentView` of the owner view.
extension UIView {
    @discardableResult
    public func fromNib<T: UIView>(named nibName: String? = nil) -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(
                nibName ?? type(of: self).objectName,
                owner: self,
                options: nil
            )?.first as? T else {
            return nil
        }
        addSubview(contentView)
        contentView.layoutToSuperview(axis: .horizontal)
        contentView.layoutToSuperview(axis: .vertical)
        return contentView
    }
}
