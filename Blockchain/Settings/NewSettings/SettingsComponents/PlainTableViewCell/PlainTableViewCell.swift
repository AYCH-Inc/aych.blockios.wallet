//
//  PlainTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

final class PlainTableViewCell: UITableViewCell {
    
    // MARK: Public IBOutlets
    
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .titleText
    }
}
