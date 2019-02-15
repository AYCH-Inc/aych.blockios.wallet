//
//  KYCTiersFooterView.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit
import PlatformUIKit

class KYCTiersFooterView: UICollectionReusableView {
    
    static let identifier: String = String(describing: KYCTiersFooterView.self)
    
    fileprivate static let verticalPadding: CGFloat = 32.0
    fileprivate static let horizontalPadding: CGFloat = 24.0

    fileprivate var trigger: ActionableTrigger?
    
    // MARK: IBOutlets
    
    @IBOutlet fileprivate var disclaimerLabel: ActionableLabel!
    
    // MARK: Public Functions
    
    func configure(with disclaimer: String) {
        disclaimerLabel.text = disclaimer
    }
    
    // MARK: Public Class Functions
    
    class func estimatedHeight(for disclaimer: String, width: CGFloat) -> CGFloat {
        let adjustedWidth = width - (horizontalPadding * 2)
        let height = NSAttributedString(
            string: disclaimer,
            attributes: [.font: disclaimerFont()]).heightForWidth(width: adjustedWidth)
        return height + verticalPadding
    }
    
    // MARK: Private Class Functions
    
    fileprivate class func disclaimerFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(12.0))
        return font.result
    }
    
}

extension KYCTiersFooterView {
    func configure(with actionableTrigger: ActionableTrigger) {
        disclaimerLabel.delegate = self
        self.trigger = actionableTrigger

        let actionableText = NSMutableAttributedString(
            string: actionableTrigger.primaryString,
            attributes: defaultAttributes()
        )

        let CTA = NSAttributedString(
            string: " " + actionableTrigger.callToAction,
            attributes: actionAttributes()
        )

        actionableText.append(CTA)

        if let secondary = actionableTrigger.secondaryString {
            let trailing = NSMutableAttributedString(
                string: " " + secondary,
                attributes: defaultAttributes()
            )
            actionableText.append(trailing)
        }

        disclaimerLabel.attributedText = actionableText
    }

    private func actionAttributes() -> [NSAttributedString.Key: Any] {
        return [.font: Font(.branded(.montserratRegular), size: .custom(12.0)).result,
         .foregroundColor: UIColor.brandSecondary]
    }

    private func defaultAttributes() -> [NSAttributedString.Key: Any] {
        return [.font: KYCTiersFooterView.disclaimerFont(),
         .foregroundColor: disclaimerLabel.textColor]
    }
}

extension KYCTiersFooterView: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        return trigger?.actionRange()
    }

    func actionRequestingExecution(label: ActionableLabel) {
        guard let trigger = trigger else { return }
        trigger.execute()
    }
}
