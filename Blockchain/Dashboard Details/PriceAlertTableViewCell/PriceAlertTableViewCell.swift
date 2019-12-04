//
//  PriceAlertTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 11/15/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class PriceAlertTableViewCell: UITableViewCell {
    
    @IBOutlet private var currentPriceLabel: UILabel!
    
    // MARK: - Lifecycle
       
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currentPriceLabel.text = LocalizationConstants.DashboardDetails.currentPrice
    }
       
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
