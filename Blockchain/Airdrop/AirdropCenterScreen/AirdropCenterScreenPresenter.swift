//
//  AirdropCenterScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

final class AirdropCenterScreenPresenter {

    // MARK: - Types
    
    enum Section {
        case started([AirdropTypeCellPresenter])
        case ended([AirdropTypeCellPresenter])
        
        var count: Int {
            return items.count
        }
        
        var items: [AirdropTypeCellPresenter] {
            switch  self {
            case .started(let presenters):
                return presenters.map { $0 }
            case .ended(let presenters):
                return presenters.map { $0 }
            }
        }
        
        var title: String {
            switch self {
            case .started:
                return LocalizationConstants.Airdrop.CenterScreen.Header.startedTitle
            case .ended:
                return LocalizationConstants.Airdrop.CenterScreen.Header.endedTitle
            }
        }
    }
    
    // MARK: - Properties
            
    /// The presenters data source for the list of airdrops
    var dataSource: [Section] {
        dataSourceRelay.value
    }
    
    let backgroundColor = UIColor.background
    
    /// Selection relay for a single presenter
    let presenterSelectionRelay = PublishRelay<AirdropTypeCellPresenter>()
    
    // MARK: - Private Accessors
    
    private let dataSourceRelay = BehaviorRelay<[Section]>(value: [])
        
    private let startedPresentersRelay = BehaviorRelay<[AirdropTypeCellPresenter]>(value: [])
    private let endedPresentersRelay = BehaviorRelay<[AirdropTypeCellPresenter]>(value: [])
    
    private let disposeBag = DisposeBag()

    // MARK: - Injected
    
    private let interactor: AirdropCenterScreenInteractor
    private let router: AirdropRouterAPI
    
    // MARK: - Setup
    
    init(router: AirdropRouterAPI,
         interactor: AirdropCenterScreenInteractor = AirdropCenterScreenInteractor()) {
        self.router = router
        self.interactor = interactor
        
        interactor.startedAirdropsInteractors
            .map { interactors in
                interactors.map { AirdropTypeCellPresenter(interactor: $0) }
            }
            .bind(to: startedPresentersRelay)
            .disposed(by: disposeBag)
        
        interactor.endedAirdropsInteractors
            .map { interactors in
                interactors.map { AirdropTypeCellPresenter(interactor: $0) }
            }
            .bind(to: endedPresentersRelay)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(startedPresentersRelay, endedPresentersRelay)
            .map { started, ended in
                return [.started(started), .ended(ended)]
            }
            .bind(to: dataSourceRelay)
            .disposed(by: disposeBag)
        
        presenterSelectionRelay
            .bind { [weak router] presenter in
                router?.presentAirdropStatusScreen(
                    for: presenter.campaignIdentifier,
                    presentationType: .navigationFromCurrent)
            }
            .disposed(by: disposeBag)
    }
    
    func refresh() {
        interactor.refresh()
    }
}
