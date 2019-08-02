//
//  ExchangeCreateContracts.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit

protocol ExchangeCreateInterface: class {
    typealias ViewUpdate = ExchangeCreateViewController.ViewUpdate
    typealias AnimatedUpdate = AnimatablePresentationUpdate<ViewUpdate>
    typealias PresentationUpdate = ExchangeCreateViewController.PresentationUpdate
    
    typealias PresentationUpdateGroup = AnimatablePresentationUpdateGroup<
        ViewUpdate,
        ExchangeCreatePresenter.InternalEvent
    >
    typealias TransitionUpdate = ExchangeCreateViewController.TransitionUpdate
    typealias AnimatedTransitionUpdate = TransitionPresentationUpdate<TransitionUpdate>
    
    typealias TransitionUpdateGroup = TransitionPresentationUpdateGroup<
        TransitionUpdate,
        ExchangeCreatePresenter.InternalEvent
    >
    
    func updateTradingPairViewValues(left: String, right: String)
    func updateTradingPairView(pair: TradingPair, fix: Fix)
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion)
    
    func apply(presentationUpdateGroup: PresentationUpdateGroup)
    func apply(transitionUpdateGroup: TransitionUpdateGroup)
    
    func apply(presentationUpdates: [PresentationUpdate])
    func apply(animatedUpdate: AnimatedUpdate)
    func apply(transitionPresentation: AnimatedTransitionUpdate)

    func exchangeStatusUpdated()
    func exchangeButtonEnabled(_ enabled: Bool)
    
    func isExchangeButtonEnabled() -> Bool

    func showTiers()
}

// Conforms to NumberKeypadViewDelegate to avoid redundancy of keypad input methods
protocol ExchangeCreateInput: NumberKeypadViewDelegate {
    func setup()
    func resume()
    func confirmationIsExecuting() -> Bool
    func confirmConversion()
    func changeMarketPair(marketPair: MarketPair)
}

protocol ExchangeCreateOutput: class {
    
    func entryRejected()
    func updatedInput(primary: NSAttributedString?, secondary: String?)
    func updateRateMetadata(_ metadata: ExchangeRateMetadata)
    func updateBalanceMetadata(_ balanceMetadata: BalanceMetadata)
    func updateTradingPairValues(left: String, right: String)
    func updateTradingPair(pair: TradingPair, fix: Fix)
    func errorReceived()
    func tradeValidationInFlight()
    func errorDismissed()
    func loadingVisibility(_ visibility: Visibility)
    func exchangeButtonVisibility(_ visibility: Visibility)
    func exchangeButtonEnabled(_ enabled: Bool)
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion)

    var status: ExchangeInteractorStatus { get }
}
