//
//  TotalBalanceTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

/// A cell that displays a total balance and asset distribution
final class TotalBalanceTableViewCell: UITableViewCell {

    // MARK: - Injected
    
    /// Presenter should be injected
    var presenter: TotalBalanceViewPresenter! {
        didSet {
            if let presenter = presenter {
                titleLabel.content = presenter.titleContent
                balanceView.presenter = presenter.balancePresenter
                pieChartView.presenter = presenter.pieChartPresenter
            } else {
                balanceView.presenter = nil
                pieChartView.presenter = nil
            }
        }
    }
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var balanceView: AssetPriceView!
    @IBOutlet private var pieChartView: AssetPieChartView!
    @IBOutlet private var bottomSeparatorView: UIView!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bottomSeparatorView.backgroundColor = .lightBorder
        balanceView.shimmer(
            estimatedPriceLabelSize: CGSize(width: 120, height: 22),
            estimatedChangeLabelSize: CGSize(width: 100, height: 14)
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
