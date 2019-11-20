//
//  DashboardNoticePresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformUIKit

final class DashboardNoticePresenter {
    
    /// MARK: - Exposed Properties
    
    /// Streams only distinct actions
    var action: Driver<NoticeDisplayAction> {
        actionRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// MARK: - Private Properties
    
    let actionRelay = BehaviorRelay<NoticeDisplayAction>(value: .hide)
    
    private let interactor: DashboardNoticeInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: DashboardNoticeInteractor) {
        self.interactor = interactor
    }
    
    func refresh() {
        interactor.lockbox
            .subscribe(onSuccess: { [weak self] shouldDisplay in
                if shouldDisplay {
                    self?.displayLockboxNotice()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func displayLockboxNotice() {
        let viewModel = NoticeViewModel(
            image: "lockbox_icon",
            labelContent: .init(
                text: LocalizationConstants.Dashboard.Balance.lockboxNotice,
                font: .mainMedium(12),
                color: .descriptionText
            )
        )
        actionRelay.accept(.show(viewModel))
    }
}
