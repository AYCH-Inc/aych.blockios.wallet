//
//  AnnouncementTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class AnnouncementTableViewCell: UITableViewCell {

    // MARK: - Lifecycle

    /// A view that represents the announcement
    private var cardView: AnnouncementCardView!
    
    var viewModel: AnnouncementCardViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            cardView = AnnouncementCardView(using: viewModel)
            contentView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
        
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.removeFromSuperview()
        cardView = nil
        viewModel = nil
    }
}
