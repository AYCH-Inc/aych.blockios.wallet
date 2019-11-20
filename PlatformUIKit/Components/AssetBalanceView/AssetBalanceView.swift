//
//  AssetBalanceView.swift
//  Blockchain
//
//  Created by AlexM on 10/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

public final class AssetBalanceView: UIView {
    
    // MARK: - Injected
    
    public var presenter: AssetBalanceViewPresenter! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else {
                return
            }
            presenter.state
                .compactMap { $0.value }
                .bind(to: rx.values)
                .disposed(by: disposeBag)
            
            presenter.state
                .filter { $0.isLoading }
                .mapToVoid()
                .bind { [weak self] in
                    self?.shimmer()
                }
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet fileprivate var fiatBalanceLabel: UILabel!
    @IBOutlet fileprivate var cryptoBalanceLabel: UILabel!
    
    fileprivate var fiatLabelShimmeringView: ShimmeringView!
    fileprivate var cryptoLabelShimmeringView: ShimmeringView!
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// Should be called once when the parent view loads
    public func shimmer(estimatedFiatLabelSize: CGSize, estimatedCryptoLabelSize: CGSize) {
        fiatLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: fiatBalanceLabel,
            size: estimatedFiatLabelSize
        )
        cryptoLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: cryptoBalanceLabel,
            size: estimatedCryptoLabelSize
        )
    }
    
    private func setup() {
        fromNib()
        shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 100, height: 14)
        )
    }
    
    private func shimmer() {
        fiatLabelShimmeringView.start()
        cryptoLabelShimmeringView.start()
    }
}

// MARK: - Rx

extension Reactive where Base: AssetBalanceView {
    var values: Binder<DashboardAsset.Value.Presentation.AssetBalance> {
        return Binder(base) { view, values in
            view.fiatBalanceLabel.content = values.fiatBalance
            view.cryptoBalanceLabel.content = values.cryptoBalance
            let animation = {
                view.fiatBalanceLabel.alpha = 1
                view.cryptoBalanceLabel.alpha = 1
                view.cryptoLabelShimmeringView.alpha = 0
                view.cryptoLabelShimmeringView.alpha = 0
            }
            let completion = { (finished: Bool) in
                view.fiatLabelShimmeringView.stop()
                view.cryptoLabelShimmeringView.stop()
                view.fiatLabelShimmeringView.removeFromSuperview()
                view.cryptoLabelShimmeringView.removeFromSuperview()
            }
            if view.cryptoLabelShimmeringView.isShimmering {
                view.fiatBalanceLabel.alpha = 0
                view.cryptoBalanceLabel.alpha = 0
                UIView.animate(
                    withDuration: 1,
                    delay: 0,
                    options: [.curveEaseInOut, .transitionCrossDissolve],
                    animations: animation,
                    completion: completion
                )
            }
        }
    }
}
