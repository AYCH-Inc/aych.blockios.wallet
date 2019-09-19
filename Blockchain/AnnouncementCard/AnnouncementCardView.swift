//
//  AnnouncementCardView.swift
//  Blockchain
//
//  Created by Maurice A. on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit

class AnnouncementCardView: UIView {

    typealias Action = () -> Void

    // MARK: - Properties

    var actionButtonPressed, closeButtonPressed: (() -> Void)?

    // MARK: - IBOutlets

    @IBOutlet private var shadowView: UIView!
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var newContainerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var bodyLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var headlineImageView: UIImageView!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var closeButton: UIButton!

    // MARK: - Initialization

    @objc class func create(withModel model: AnnouncementCardViewModel) -> AnnouncementCardView {
        let cardView = AnnouncementCardView.makeFromNib()
        cardView.headlineImageView.isHidden = model.palette.headlineImage == nil
        cardView.headlineImageView.image = model.palette.headlineImage
        cardView.backgroundImageView.isHidden = model.palette.backgroundImage == nil
        cardView.backgroundImageView.image = model.palette.backgroundImage
        cardView.backgroundImageView.contentMode = model.palette.contentMode
        cardView.backgroundImageView.clipsToBounds = true
        cardView.backgroundImageView.layer.cornerRadius = 8.0
        cardView.newContainerView.isHidden = model.palette.isNew == false
        cardView.newContainerView.layer.cornerRadius = 4.0
        cardView.titleLabel.isHidden = model.title == nil
        cardView.titleLabel.textColor = model.palette.titleTextColor
        cardView.bodyLabel.textColor = model.palette.messageTextColor
        cardView.actionButton.setImage(model.palette.disclosureImage, for: .normal)
        cardView.actionButton.setTitleColor(model.palette.actionTextColor, for: .normal)
        cardView.actionButton.semanticContentAttribute = UIApplication.shared
        .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        cardView.shadowView.backgroundColor = model.palette.backgroundColor
        cardView.titleLabel.text = model.title
        cardView.bodyLabel.text = model.message
        cardView.imageView.image = model.image
        if let tint = model.imageTint {
            cardView.imageView.tintColor = tint
        }
        cardView.actionButton.setTitle(model.actionButtonTitle, for: .normal)
        cardView.actionButton.isHidden = (model.actionButtonTitle == nil)
        cardView.actionButtonPressed = model.action
        cardView.closeButtonPressed = model.onClose
        return cardView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .gray4
        closeButton.accessibilityIdentifier = AccessibilityIdentifiers.AnnouncementCard.dismissButton
        actionButton.accessibilityIdentifier = AccessibilityIdentifiers.AnnouncementCard.actionButton
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowView.layer.shadowColor = #colorLiteral(red: 0.87, green: 0.87, blue: 0.87, alpha: 1).cgColor
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowOffset = .init(width: 0, height: 2.0)
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.cornerRadius = 8.0
    }

    // MARK: - IBActions

    @IBAction private func actionButtonPressed(_ sender: Any) {
        guard let action = actionButtonPressed else {
            Logger.shared.error("No action assigned to the action button!"); return
        }
        action()
    }

    @IBAction private func closeButtonPressed(_ sender: Any) {
        guard let close = closeButtonPressed else {
            Logger.shared.error("No action assigned to the close button!"); return
        }
        close()
    }
}
