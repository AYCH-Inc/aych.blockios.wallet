//
//  NSAttributedString+Conveniences.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    public var height: CGFloat {
        return heightForWidth(width: CGFloat.greatestFiniteMagnitude)
    }
    
    public var width: CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let rect = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.width)
    }
    
    public func boundingRectForWidth(_ width: CGFloat) -> CGRect {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesDeviceMetrics], context: .none)
    }
    
    public func fontAttribute() -> UIFont? {
        guard length > 0 else { return nil }
        guard let font = attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return nil }
        return font
    }
    
    public func heightForWidth(width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: width == CGFloat.greatestFiniteMagnitude ? 0 : CGFloat.greatestFiniteMagnitude)
        let rect = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.height)
    }
    
    public func withFont(_ font: UIFont) -> NSAttributedString {
        if fontAttribute() == .none {
            let copy = NSMutableAttributedString(attributedString: self)
            copy.addAttribute(.font, value: font, range: NSMakeRange(0, copy.length))
            return copy
        }
        return copy() as! NSAttributedString
    }
    
    public func asBulletPoint() -> NSAttributedString {
        let bullet = NSMutableAttributedString(
            string: "\u{2022} ",
            attributes: [
                .font: fontAttribute() ?? UIFont.systemFont(ofSize: 17.0)
            ]
        )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = bullet.width
        let copy = NSMutableAttributedString(attributedString: self)
        bullet.append(copy)
        bullet.addAttributes(
            [.paragraphStyle: paragraphStyle,
             .font: fontAttribute() ?? UIFont.systemFont(ofSize: 17.0)
            ],
            range: NSMakeRange(0, bullet.length)
        )
        return bullet
    }
}

extension Sequence where Element: NSAttributedString {
    
    func join(withSeparator separator: NSAttributedString? = nil) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for (index, string) in enumerated() {
            if index > 0 {
                if let separator = separator {
                    result.append(separator)
                }
            }
            result.append(string)
        }
        return result
    }
}
