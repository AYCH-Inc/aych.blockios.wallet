//
//  PreferredCurrencyBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class PreferredCurrencyBadgeInteractor: BadgeAssetInteracting {
    
    typealias InteractionState = BadgeAsset.State.BadgeItem.Interaction
    typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
        
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(settingsService: SettingsServiceAPI,
         fiatCurrencyProvider: FiatCurrencyTypeProviding) {
        let settingsFiatCurrency = settingsService.state
            .compactMap { $0.value }
            .map { $0.fiatCurrency }
        let fiatCurrency = fiatCurrencyProvider.fiatCurrency
        let currencyNames = CurrencySymbol.currencyNames()!
        
        Observable
            .combineLatest(settingsFiatCurrency, fiatCurrency)
            .map { currencyInfo -> BadgeItem in
                let currency = currencyInfo.0
                let description = currencyNames[currency] as? String ?? currency
                let title = "\(description) (\(currencyInfo.1.symbol))"
                return BadgeItem(type: .default, description: title)
            }
            .map { .loaded(next: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
