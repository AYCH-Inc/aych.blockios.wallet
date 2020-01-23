//
//  ClipboardTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

final class ClipboardTableViewCell: UITableViewCell {
    
    // MARK: Public IBOutlets
    
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .titleText
    }
}
