//
//  AssetPriceView.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public final class AssetPriceView: UIView {
    
    // MARK: - Injected
    
    public var presenter: AssetPriceViewPresenter! {
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
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet fileprivate var priceLabel: UILabel!
    @IBOutlet fileprivate var changeLabel: UILabel!

    fileprivate var priceLabelShimmeringView: ShimmeringView!
    fileprivate var changeLabelShimmeringView: ShimmeringView!
    
    private var disposeBag = DisposeBag()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// Should be called once when the parent view loads
    public func shimmer(estimatedPriceLabelSize: CGSize,
                        estimatedChangeLabelSize: CGSize) {
        priceLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: priceLabel,
            size: estimatedPriceLabelSize
        )
        changeLabelShimmeringView = ShimmeringView(
            in: self,
            anchorView: changeLabel,
            size: estimatedChangeLabelSize
        )
    }
    
    private func setup() {
        fromNib()
    }
    
    private func shimmer() {
        priceLabelShimmeringView.start()
        changeLabelShimmeringView.start()
    }
}

// MARK: - Rx

extension Reactive where Base: AssetPriceView {
    var values: Binder<DashboardAsset.Value.Presentation.AssetPrice> {
        return Binder(base) { view, values in
            view.priceLabel.content = values.price
            view.changeLabel.attributedText = values.change
            view.changeLabel.accessibility = values.changeAccessibility
            let animation = {
                view.priceLabel.alpha = 1
                view.changeLabel.alpha = 1
                view.priceLabelShimmeringView.alpha = 0
                view.changeLabelShimmeringView.alpha = 0
            }
            let completion = { (finished: Bool) in
                view.priceLabelShimmeringView.stop()
                view.changeLabelShimmeringView.stop()
                view.priceLabelShimmeringView.removeFromSuperview()
                view.changeLabelShimmeringView.removeFromSuperview()
            }
            if view.priceLabelShimmeringView.isShimmering {
                view.changeLabel.alpha = 0
                view.priceLabel.alpha = 0
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
