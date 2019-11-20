//
//  HistoricalBalanceTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 10/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformKit
import PlatformUIKit

final class HistoricalBalanceTableViewCell: UITableViewCell {
    
    /// Presenter should be injected
    var presenter: HistoricalBalanceCellPresenter! {
        didSet {
            disposeBag = DisposeBag()
            if let presenter = presenter {
                assetSparklineView.presenter = presenter.sparklinePresenter
                assetPriceView.presenter = presenter.pricePresenter
                assetBalanceView.presenter = presenter.balancePresenter
                setup()
            } else {
                assetSparklineView.presenter = nil
                assetPriceView.presenter = nil
                assetBalanceView.presenter = nil
            }
        }
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var assetTitleLabel: UILabel!
    @IBOutlet private var assetImageView: UIImageView!
    @IBOutlet private var assetSparklineView: AssetSparklineView!
    @IBOutlet private var assetPriceView: AssetPriceView!
    @IBOutlet private var assetBalanceView: AssetBalanceView!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var bottomSeparatorView: UIView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lightBorder
        bottomSeparatorView.backgroundColor = .lightBorder
        assetPriceView.shimmer(
            estimatedPriceLabelSize: CGSize(width: 84, height: 16),
            estimatedChangeLabelSize: CGSize(width: 62, height: 14)
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
    
    private func setup() {
        presenter.thumbnail
            .drive(assetImageView.rx.content)
            .disposed(by: disposeBag)
        presenter.name
            .drive(assetTitleLabel.rx.content)
            .disposed(by: disposeBag)
    }
}
