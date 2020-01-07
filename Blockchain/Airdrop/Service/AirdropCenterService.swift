//
//  AirdropCenterService.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

protocol AirdropCenterServiceAPI: class {
    
    var campaignsCalculationState: Observable<ValueCalculationState<AirdropCampaigns>> { get }
    
    /// An `Observable` that streams the airdrop campaigns
    func fetchCampaignsCalculationState(useCache: Bool) -> Observable<ValueCalculationState<AirdropCampaigns>>
    
    /// An `Observable` that streams an airdrop campaign by name
    func fetchCampaignCalculationState(campaignName: AirdropCampaigns.Campaign.Name,
                                       useCache: Bool) -> Observable<ValueCalculationState<AirdropCampaigns.Campaign>>
    
    /// Triggers a refresh on the service
    func refresh()
}

/// TODO: Move into `PlatformKit` when https://blockchain.atlassian.net/browse/IOS-2724 is merged
final class AirdropCenterService: AirdropCenterServiceAPI {
            
    /// TODO: Remove `shared` and place in `UserInformationServiceProvider`.
    static let shared = AirdropCenterService()
    
    var campaignsCalculationState: Observable<ValueCalculationState<AirdropCampaigns>> {
        campaignsCalculationStateRelay.asObservable()
    }
    
    private let campaignsCalculationStateRelay = BehaviorRelay<ValueCalculationState<AirdropCampaigns>>(value: .invalid(.empty))
    private let fetchTriggerRelay = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected (Privately used)
    
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: AirdropCenterClientAPI
    
    // MARK: - Setup
    
    init(authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         client: AirdropCenterClientAPI = AirdropCenterClient()) {
        self.authenticationService = authenticationService
        self.client = client
        
        fetchTriggerRelay
            .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest(weak: self) { (self, campaigns) -> Observable<AirdropCampaigns> in
                self.fetchCampaigns().asObservable()
            }
            .map { .value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .bind(to: campaignsCalculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    /// Refreshes the campaigns
    func refresh() {
        fetchTriggerRelay.accept(())
    }
    
    func fetchCampaignsCalculationState(useCache: Bool) -> Observable<ValueCalculationState<AirdropCampaigns>> {
        campaignsCalculationState
            .do(onSubscribed: { [weak self] in
                guard let self = self else { return }
                if self.campaignsCalculationStateRelay.value.isInvalid || !useCache {
                    self.refresh()
                }
            })
    }
    
    func fetchCampaignCalculationState(campaignName: AirdropCampaigns.Campaign.Name,
                                       useCache: Bool) -> Observable<ValueCalculationState<AirdropCampaigns.Campaign>> {
        return fetchCampaignsCalculationState(useCache: useCache)
            .map { state in
                switch state {
                case .value(let campaigns):
                    if let campaign = campaigns.campaign(by: campaignName) {
                        return .value(campaign)
                    } else {
                        return .invalid(.valueCouldNotBeCalculated)
                    }
                case .invalid(.empty):
                    return .invalid(.empty)
                case .calculating:
                    return .calculating
                case .invalid:
                    return .invalid(.valueCouldNotBeCalculated)
                }
            }
    }
    
    // MARK: - Accessors
    
    private func fetchCampaigns() -> Single<AirdropCampaigns> {
        return authenticationService
            .getSessionToken()
            .flatMap(weak: self) { (self, token) -> Single<AirdropCampaigns> in
                self.client.campaigns(using: token.token)
            }
    }
}
