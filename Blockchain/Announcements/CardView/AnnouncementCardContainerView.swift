//
//  AnnouncementCardContainerView.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit

// TODO: Temporary solution until the dashboard is refactored as a `UIViewController`
// that contains a `UICollectionView`. Once refactored, this class should become a
// `UICollectionViewCell` / `UITableViewCell` and wrap the currencly presented
// announcement card.

// TODO: Remove once we use collection view and the size can be estimated automatically
protocol AnnouncementCardContainerDelegate: class {
    func didUpdateAnnouncementCardHeight(_ cardHeight: CGFloat)
}

final class AnnouncementCardContainerView: UIView {
    
    // MARK: Properties

    private let presenter: AnnouncementPresenter
    private let disposeBag = DisposeBag()
    
    /// A delegate to estimate the size of the card inside the dashboard
    private unowned let delegate: AnnouncementCardContainerDelegate
    
    /// Currently presented card
    private weak var cardView: UIView!
    
    // MARK: - Setup
    
    // TODO: Remove `parentScrollView`, `parentView` once the dashboard is recfactored and Self becomes a cell.
    init(presenter: AnnouncementPresenter = AnnouncementPresenter(),
         superview: UIView,
         delegate: AnnouncementCardContainerDelegate) {
        self.delegate = delegate
        self.presenter = presenter
        super.init(frame: UIScreen.main.bounds)
        
        superview.addSubview(self)
        layoutToSuperview(.horizontal)
        let heightConstraint = heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.priority = .defaultHigh
        presenter.announcement
            .drive(onNext: { [weak self] action in
                self?.execute(action: action)
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh() {
        presenter.refresh()
    }
    
    /// Shows / hides announcement
    private func execute(action: AnnouncementDisplayAction) {
        Logger.shared.debug("Executing action: \(action.debugDescription)")
        switch action {
        case .show(let viewModel):
            show(using: viewModel)
        case .hide:
            hide()
        case .none:
            break
        }
    }
    
    private func hide() {
        if let cardView = cardView {
            cardView.removeFromSuperview()
        }
        layoutIfNeeded()
        delegate.didUpdateAnnouncementCardHeight(0)
    }
    
    private func show(using viewModel: AnnouncementCardViewModel) {
        hide()
        let cardView = AnnouncementCardView(using: viewModel)
        addSubview(cardView)
        cardView.layoutToSuperview(.horizontal, .vertical)
        self.cardView = cardView
        layoutIfNeeded()
        delegate.didUpdateAnnouncementCardHeight(bounds.height)
    }
}
