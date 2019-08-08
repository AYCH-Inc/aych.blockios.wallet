//
//  CardsViewController+KYC.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit

/// This class is a workaround for Swift-ObjC interoperability when involving RxSwift code.
/// It is handy in times we want to extend an ObjC class using Swift (gradual migration).
@objc
class BridgedDisposeBag: NSObject {
    let bag = DisposeBag()
}

// TICKET: IOS-1249 - Refactor CardsViewController
/// TODO: Gradually migrate `CardsViewController` logic here, until ObjC class is safely removed
extension CardsViewController {
    @objc func tearDownNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func setupAnnouncements() {
        
        // TODO: RxSwift doesn't work in Obj-C, so `CardsDisposeBag` wraps Rx's bag.
        /// Upon migrating `CardsViewController` to `Swift`, strip and place `bag`.
        disposeBag = BridgedDisposeBag()
        
        // TODO: Inject into CardsViewContorller, when moving to `Swift`.
        announcementPresenter = AnnouncementPresenter()
        announcementPresenter.announcement.drive(onNext: { [weak self] action in
            self?.execute(action: action)
        })
        .disposed(by: disposeBag.bag)
    }
    
    /// Shows / hides an alert / card
    private func execute(action: AnnouncementDisplayAction) {
        Logger.shared.debug("Executing action: \(action.debugDescription)")
        switch action {
        case .show(let type):
            show(announcementType: type)
        case .hide:
            animateHideCards()
        case .none:
            break
        }
    }
    
    private func show(announcementType: AnnouncementType) {
        switch announcementType {
        case .alert(let viewModel):
            showAlert(using: viewModel)
        case .card(let viewModel):
            showCard(using: viewModel)
        case .welcomeCards:
            showWelcomeCards()
        }
    }
    
    private func showWelcomeCards() {
        reloadWelcomeCards()
        dashboardScrollView.contentSize = CGSize(
            width: view.frame.size.width,
            height: dashboardContentView.frame.size.height + cardsViewHeight
        )
    }
    
    private func showAlert(using viewModel: AlertModel) {
        let alert = AlertView.make(with: viewModel) { action in
            action.metadata?.block?()
        }
        alert.show()
    }
    
    private func showCard(using viewModel: AnnouncementCardViewModel) {
        showSingleCard(with: viewModel)
        dashboardScrollView.contentSize = CGSize(
            width: view.frame.size.width,
            height: dashboardContentView.frame.size.height + cardsViewHeight
        )
    }
    
    @objc func reloadAllCards() {
        loadViewIfNeeded()
        announcementPresenter.refresh()
    }
}
