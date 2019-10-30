//
//  ExchangeServices.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import StellarKit
import PlatformKit

protocol ExchangeDependencies {
    var service: ExchangeHistoryAPI { get }
    var markets: ExchangeMarketsAPI { get }
    var conversions: ExchangeConversionAPI { get }
    var inputs: ExchangeInputsAPI { get }
    var tradeExecution: TradeExecutionAPI { get }
    var assetAccountRepository: AssetAccountRepository { get }
    var tradeLimits: TradeLimitsAPI { get }
    var analyticsRecorder: AnalyticsEventRecording { get }
}

struct ExchangeServices: ExchangeDependencies {
    let service: ExchangeHistoryAPI
    let markets: ExchangeMarketsAPI
    var conversions: ExchangeConversionAPI
    let inputs: ExchangeInputsAPI
    let tradeExecution: TradeExecutionAPI
    let assetAccountRepository: AssetAccountRepository
    let tradeLimits: TradeLimitsAPI
    let analyticsRecorder: AnalyticsEventRecording
    
    init() {
        service = ExchangeService()
        markets = MarketsService()
        conversions = ExchangeConversionService()
        inputs = ExchangeInputsService()
        assetAccountRepository = AssetAccountRepository.shared
        tradeExecution = TradeExecutionService(
            wallet: WalletManager.shared.wallet,
            dependencies: TradeExecutionService.Dependencies()
        )
        tradeLimits = TradeLimitsService()
        analyticsRecorder = AnalyticsEventRecorder.shared
    }
}
