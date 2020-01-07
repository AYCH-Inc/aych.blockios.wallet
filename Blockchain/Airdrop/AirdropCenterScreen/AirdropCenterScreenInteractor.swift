//
//  AirdropCenterScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

final class AirdropCenterScreenInteractor {
    
    // MARK: - Interactors
    
    var startedAirdropsInteractors: Observable<[AirdropTypeCellInteractor]> {
        return startedAirdropsInteractorsRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    var endedAirdropsInteractors: Observable<[AirdropTypeCellInteractor]> {
        return endedAirdropsInteractorsRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    private let startedAirdropsInteractorsRelay = BehaviorRelay<[AirdropTypeCellInteractor]>(value: [])
    private let endedAirdropsInteractorsRelay = BehaviorRelay<[AirdropTypeCellInteractor]>(value: [])
    
    // MARK: - Injected Services
    
    private let service: AirdropCenterServiceAPI
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    /// use `UserInformationServiceProvider` when merged into `dev`.
    init(service: AirdropCenterServiceAPI = AirdropCenterService.shared) {
        self.service = service
        
        let allCampaigns = service.campaignsCalculationState
            .compactMap { $0.value?.campaigns }
            .map { campaigns in
                 campaigns
                    .sorted { (lhs, rhs) -> Bool in
                        let lhsDate = lhs.dropDate ?? .distantFuture
                        let rhsDate = rhs.dropDate ?? .distantFuture
                        return lhsDate > rhsDate
                    }
            }
        
        allCampaigns
            .map { campaigns in
                return campaigns.filter { $0.state == .started }
            }
            .map { campaigns in
                return campaigns.map { AirdropTypeCellInteractor(campaign: $0) }
            }
            .bind(to: startedAirdropsInteractorsRelay)
            .disposed(by: disposeBag)
        
        allCampaigns
            .map { campaigns in
                return campaigns.filter { $0.state == .ended }
            }
            .map { campaigns in
                return campaigns.map { AirdropTypeCellInteractor(campaign: $0) }
            }
            .bind(to: endedAirdropsInteractorsRelay)
            .disposed(by: disposeBag)
    }
    
    func refresh() {
        service.refresh()
    }
}
