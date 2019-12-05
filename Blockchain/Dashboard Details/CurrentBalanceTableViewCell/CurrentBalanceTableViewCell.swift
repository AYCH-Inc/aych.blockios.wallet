//
//  CurrentBalanceTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit
import PlatformUIKit

final class CurrentBalanceTableViewCell: UITableViewCell {
    
    var presenter: AssetBalanceViewPresenter! {
        didSet {
            assetBalanceView.presenter = presenter
        }
    }
    
    var currency: CryptoCurrency! {
        didSet {
            currencyImageView.image = currency.logo
            currencyType.text = currency.description
            currencyTypeDescription.text = "\(LocalizationConstants.Swap.your) \(currency.rawValue) \(LocalizationConstants.Swap.balance)"
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var currencyImageView: UIImageView!
    @IBOutlet private var currencyType: UILabel!
    @IBOutlet private var currencyTypeDescription: UILabel!
    @IBOutlet private var assetBalanceView: AssetBalanceView!
    
    // MARK: - Lifecycle
       
    override func awakeFromNib() {
        super.awakeFromNib()
    }
       
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
