//
//  AirdropStatusScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class AirdropStatusScreenInteractor {

    // MARK: - Exposed Properties

    /// Streams the calculation state of the campaign
    var calculationState: Observable<ValueCalculationState<AirdropCampaigns.Campaign>> {
        return calculationStateRelay.asObservable()
    }
    
    // MARK: - Injected Properties
    
    private let service: AirdropCenterServiceAPI
    
    // MARK: - Rx Accessors
    
    private let calculationStateRelay = BehaviorRelay<ValueCalculationState<AirdropCampaigns.Campaign>>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(service: AirdropCenterServiceAPI = AirdropCenterService.shared,
         campaignName: AirdropCampaigns.Campaign.Name) {
        self.service = service
        service.fetchCampaignCalculationState(campaignName: campaignName, useCache: true)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
