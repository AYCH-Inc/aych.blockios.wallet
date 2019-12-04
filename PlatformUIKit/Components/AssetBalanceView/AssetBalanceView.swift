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
            
            presenter.alignment
                .drive(stackView.rx.alignment)
                .disposed(by: disposeBag)
            
            presenter.state
                .compactMap { $0.value }
                .bind(to: rx.values)
                .disposed(by: disposeBag)
            
            presenter.state
                .map { $0.isLoading }
                .mapToVoid()
                .bind { [weak self] in
                    self?.startShimmering()
                }
                .disposed(by: disposeBag)
                
            presenter.state
                .filter { $0.isLoading == false }
                .mapToVoid()
                .bind { [weak self] in
                    self?.stopShimmering()
                }
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var stackView: UIStackView!
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
    
    private func stopShimmering() {
        guard fiatLabelShimmeringView.isShimmering && cryptoLabelShimmeringView.isShimmering else { return }
        
        fiatBalanceLabel.alpha = 0
        cryptoBalanceLabel.alpha = 0
        
        let animation = {
            self.fiatBalanceLabel.alpha = 1
            self.cryptoBalanceLabel.alpha = 1
            self.fiatLabelShimmeringView.stop()
            self.cryptoLabelShimmeringView.stop()
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .transitionCrossDissolve],
            animations: animation
        )
    }
    
    private func startShimmering() {
        guard fiatBalanceLabel.content.isEmpty() else { return }
        guard cryptoBalanceLabel.content.isEmpty() else { return }
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
        }
    }
}
