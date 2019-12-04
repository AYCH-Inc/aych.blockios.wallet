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
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet fileprivate var priceLabel: UILabel!
    @IBOutlet fileprivate var changeLabel: UILabel!
    @IBOutlet fileprivate var stackView: UIStackView!

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
    
    private func setup() {
        fromNib()
        setNeedsLayout()
        layoutIfNeeded()
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
    
    private func stopShimmering() {
        guard priceLabelShimmeringView.isShimmering && changeLabelShimmeringView.isShimmering else { return }
        
        changeLabel.alpha = 0
        priceLabel.alpha = 0
        
        let animation = {
            self.priceLabel.alpha = 1
            self.changeLabel.alpha = 1
            self.priceLabelShimmeringView.stop()
            self.changeLabelShimmeringView.stop()
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .transitionCrossDissolve],
            animations: animation
        )
    }
    
    private func startShimmering() {
        guard priceLabel.content.isEmpty() else { return }
        guard changeLabel.content.isEmpty() else { return }
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
        }
    }
}
