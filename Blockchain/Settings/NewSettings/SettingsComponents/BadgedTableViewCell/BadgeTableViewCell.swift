//
//  BadgeTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

final class BadgeTableViewCell: UITableViewCell {
    
    // MARK: - Public Properites
    
    var presenter: BadgeCellPresenting! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else { return }
            presenter.badgeAssetPresenting.state
                .compactMap { $0 }
                .bind(to: rx.viewModel)
                .disposed(by: disposeBag)
            
            presenter.labelContentPresenting.state
                .compactMap { $0 }
                .bind(to: rx.content)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var badgeView: BadgeView!
    
    // MARK: - Private Properties
    
    private var disposeBag = DisposeBag()
    fileprivate var badgeShimmeringView: ShimmeringView!
    fileprivate var titleShimmeringView: ShimmeringView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shimmer()
        titleLabel.textColor = .titleText
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
    
    /// Should be called once when the parent view loads
    private func shimmer() {
        badgeShimmeringView = ShimmeringView(
            in: self,
            anchorView: badgeView,
            size: .init(width: 75, height: 24)
        )
        titleShimmeringView = ShimmeringView(
            in: self,
            anchorView: titleLabel,
            size: .init(width: 150, height: 24)
        )
    }
}

// MARK: - Rx

extension Reactive where Base: BadgeTableViewCell {
    var viewModel: Binder<BadgeAsset.State.BadgeItem.Presentation> {
        return Binder(base) { view, state in
            let loading = {
                view.badgeShimmeringView.start()
            }
            
            switch state {
            case .loading:
                UIView.animate(withDuration: 0.5, animations: loading)
            case .loaded(next: let value):
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCrossDissolve, animations: {
                    view.badgeView.viewModel = value.viewModel
                    view.badgeShimmeringView.stop()
                }, completion: nil)
            }
        }
    }
    
    var content: Binder<LabelContentAsset.State.LabelItem.Presentation> {
        return Binder(base) { view, state in
            let loading = {
                view.titleShimmeringView.start()
            }
            
            switch state {
            case .loading:
                UIView.animate(withDuration: 0.5, animations: loading)
            case .loaded(next: let value):
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCrossDissolve, animations: {
                    view.titleLabel.content = value.labelContent
                    view.titleShimmeringView.stop()
                }, completion: nil)
            }
        }
    }
}
