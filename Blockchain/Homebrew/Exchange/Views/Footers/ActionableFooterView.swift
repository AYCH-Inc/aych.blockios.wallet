//
//  ActionableFooterView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
import PlatformUIKit

class ActionableFooterView: UICollectionReusableView {
    
    static let identifier: String = String(describing: ActionableFooterView.self)
    
    // MARK: Private Static Properties
    
    fileprivate static let verticalPadding: CGFloat = 32.0
    fileprivate static let stackViewVerticalPadding: CGFloat = 8.0
    fileprivate static let horizontalPadding: CGFloat = 32.0
    fileprivate static let actionHeight: CGFloat = 56.0
    
    // MARK: Public
    
    var actionBlock: (() -> Void)?
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var action: UIButton!
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        action.layer.cornerRadius = 4.0
        action.accessibilityIdentifier = Accessibility.Identifier.General.mainCTAButton
    }
    
    // MARK: Public Functions
    
    func configure(_ model: ActionableFooterModel) {
        action.isEnabled = model.enabled
        action.setTitle(model.title, for: .normal)
        descriptionLabel.isHidden = model.description == nil
        if let value = model.description {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            descriptionLabel.attributedText = NSAttributedString(
                string: value,
                attributes: [.font: model.descriptionFont,
                             .foregroundColor: model.tintColor,
                             .paragraphStyle: paragraphStyle]
            )
        }
    }
    
    // MARK: Private Static Functions
    
    fileprivate func descriptionFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(12.0))
        return font.result
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        actionBlock?()
    }
    
    // MARK: Public Static Functions
    
    static func height(with model: ActionableFooterModel, width: CGFloat) -> CGFloat {
        let padding = verticalPadding + (model.description == nil ? 0.0 : stackViewVerticalPadding)
        var descriptionHeight: CGFloat = 0
        if let value = model.description {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributed = NSAttributedString(
                string: value,
                attributes: [.font: model.descriptionFont,
                             .foregroundColor: model.tintColor,
                             .paragraphStyle: paragraphStyle]
            )
            descriptionHeight = attributed.heightForWidth(width: width - horizontalPadding)
        }
        
        return padding + actionHeight + descriptionHeight
    }
}

struct ActionableFooterModel {
    let title: String
    let enabled: Bool
    let description: String?
    
    init(title: String, enabled: Bool = true, description: String? = nil) {
        self.title = title
        self.enabled = enabled
        self.description = description
    }
}

extension ActionableFooterModel {
    
    var descriptionFont: UIFont {
        switch enabled {
        case false:
            let font = Font(.branded(.montserratRegular), size: .custom(14.0))
            return font.result
        case true:
            let isAboveSE = UIDevice.current.type.isAbove(.iPhoneSE)
            switch isAboveSE {
            case true:
                let font = Font(.branded(.montserratRegular), size: .custom(16.0))
                return font.result
            case false:
                let font = Font(.branded(.montserratRegular), size: .custom(12.0))
                return font.result
            }
        }
    }
    
    var tintColor: UIColor {
        switch enabled {
        case false:
            return #colorLiteral(red: 0.95, green: 0.42, blue: 0.34, alpha: 1)
        case true:
            return #colorLiteral(red: 0.64, green: 0.64, blue: 0.64, alpha: 1)
        }
    }
}
