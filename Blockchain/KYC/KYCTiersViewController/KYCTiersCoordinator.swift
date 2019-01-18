//
//  KYCTiersCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class KYCTiersCoordinator {
    
    private let limitsAPI: TradeLimitsAPI = ExchangeServices().tradeLimits
    private var disposable: Disposable?
    private weak var interface: KYCTiersInterface?
    
    init(interface: KYCTiersInterface?) {
        self.interface = interface
    }
    
    func refreshViewModel(withCurrencyCode code: String = "USD", suppressCTA: Bool = false) {
        interface?.collectionViewVisibility(.hidden)
        interface?.loadingIndicator(.visible)
        
        let limitsObservable = limitsAPI.getTradeLimits(withFiatCurrency: code, ignoringCache: true)
            .optional()
            .catchErrorJustReturn(nil)
            .asObservable()
        
        disposable = Observable.zip(
            BlockchainDataRepository.shared.tiers,
            limitsObservable
        )
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (response, limits) in
                guard let this = self else { return }
                let formatter: NumberFormatter = NumberFormatter.localCurrencyFormatterWithGroupingSeparator
                let max = NSDecimalNumber(decimal: limits?.maxTradableToday ?? 0)
                let header = KYCTiersHeaderViewModel.make(
                    with: response,
                    availableFunds: formatter.string(from: max),
                    suppressDismissCTA: suppressCTA
                )
                let filtered = response.userTiers.filter({ $0.tier != .tier0 })
                let cells = filtered.map({ return KYCTierCellModel.model(from: $0) }).compactMap({ return $0 })
                
                let page = KYCTiersPageModel(header: header, cells: cells)
                this.interface?.apply(page)
                this.interface?.loadingIndicator(.hidden)
                this.interface?.collectionViewVisibility(.visible)
            }, onError: { [weak self] _ in
                guard let this = self else { return }
                this.interface?.loadingIndicator(.hidden)
                this.interface?.collectionViewVisibility(.visible)
            })
    }
}
