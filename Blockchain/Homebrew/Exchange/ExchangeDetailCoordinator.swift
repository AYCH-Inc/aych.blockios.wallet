//
//  ExchangeDetailCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit
import PlatformKit
import RxSwift

protocol ExchangeDetailCoordinatorDelegate: class {
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, updated model: ExchangeDetailPageModel)
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, completedTransaction: OrderTransaction)
}

// TICKET: IOS-1918 - Refactor `ExchangeDetailCoordinator` into separate classes
class ExchangeDetailCoordinator: NSObject {
    
    private typealias AccessibilityIdentifier = AccessibilityIdentifiers.Exchange.Details
    
    enum Event {
        case pageLoaded(ExchangeDetailPageModel)
        case confirmExchange(OrderTransaction)
        case updateConfirmDetails(OrderTransaction, Conversion)
    }

    fileprivate weak var delegate: ExchangeDetailCoordinatorDelegate?
    fileprivate weak var interface: ExchangeDetailInterface?
    
    fileprivate var current: ExchangeDetailPageModel!
    
    fileprivate let tradeExecution: TradeExecutionAPI
    fileprivate let tradeLimitsService: TradeLimitsAPI
    fileprivate var accountRepository: AssetAccountRepository {
        get {
            return AssetAccountRepository.shared
        }
    }
    fileprivate var fiatCurrencyCode: String = {
        return BlockchainSettings.App.shared.fiatCurrencyCode
    }()
    fileprivate var fiatCurrencySymbol: String = {
        return BlockchainSettings.App.shared.fiatCurrencySymbol
    }()
    fileprivate var bus: WalletActionEventBus = {
        return WalletActionEventBus()
    }()
    fileprivate let disposables = CompositeDisposable()

    init(
        delegate: ExchangeDetailCoordinatorDelegate,
        interface: ExchangeDetailInterface,
        dependencies: ExchangeDependencies
    ) {
        self.delegate = delegate
        self.interface = interface
        self.tradeLimitsService = dependencies.tradeLimits
        self.tradeExecution = dependencies.tradeExecution
        super.init()
    }

// swiftlint:disable function_body_length
    func handle(event: Event) {
        switch event {
        case .updateConfirmDetails(let orderTransaction, let conversion):
            interface?.mostRecentConversion = conversion
            let model = ExchangeDetailPageModel(type: .confirm(orderTransaction, conversion))
            handle(event: .pageLoaded(model))
        case .pageLoaded(let model):
            current = model
            
            var cellModels: [ExchangeCellModel] = []

            switch model.pageType {
            case .confirm(let orderTransaction, let conversion):
                let currencyType = orderTransaction.destination.balance.currencyType
                let disposable = accountRepository.nameOfAccountContaining(
                    address: orderTransaction.destination.address.address,
                    currencyType: currencyType
                    ).asObservable()
                    .take(1)
                    .subscribeOn(MainScheduler.asyncInstance)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self] name in
                        guard let self = self else { return }
                        self.interface?.updateBackgroundColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                        self.interface?.updateNavigationBar(appearance: NavigationBarAppearanceLight, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                        self.interface?.updateTitle(LocalizationConstants.Swap.confirmSwap)
                        
                        let pair = ExchangeCellModel.TradingPair(
                            model: TradingPairView.confirmationModel(for: conversion)
                        )
                        
                        let value = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.value,
                            value: self.valueString(
                                for: conversion.quote.currencyRatio.counter.fiat.value,
                                currencyCode: conversion.quote.currencyRatio.counter.fiat.symbol
                            ),
                            backgroundColor: #colorLiteral(red: 0.96, green: 0.97, blue: 0.98, alpha: 1),
                            descriptionAccessibilityId: AccessibilityIdentifier.fiatDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.fiatValueLabel
                        )
                        
                        let from = orderTransaction.from.address.assetType
                        let feeAssetType = from.isERC20 ? .ethereum : from
                        
                        let fees = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.fees,
                            value: orderTransaction.fees + " " + feeAssetType.symbol,
                            backgroundColor: #colorLiteral(red: 0.96, green: 0.97, blue: 0.98, alpha: 1),
                            descriptionAccessibilityId: AccessibilityIdentifier.feesDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.feesValueLabel
                        )
                        
                        let receive = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.receive,
                            value: orderTransaction.amountToReceive + " " + TradingPair(string: conversion.quote.pair)!.to.symbol,
                            backgroundColor: #colorLiteral(red: 0.96, green: 0.97, blue: 0.98, alpha: 1),
                            bold: true,
                            descriptionAccessibilityId: AccessibilityIdentifier.receiveDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.receiveValueLabel
                        )
                        
                        let sendTo = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.sendTo,
                            value: name,
                            backgroundColor: #colorLiteral(red: 0.96, green: 0.97, blue: 0.98, alpha: 1),
                            descriptionAccessibilityId: AccessibilityIdentifier.destinationDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.destinationValueLabel
                        )
                        
                        cellModels.append(contentsOf: [
                            .tradingPair(pair),
                            .plain(value),
                            .plain(fees),
                            .plain(receive),
                            .plain(sendTo)
                            ]
                        )
                        
                        let footer = ActionableFooterModel(
                            title: LocalizationConstants.Exchange.confirm,
                            description: LocalizationConstants.Exchange.amountVariation +  " \n\n " + LocalizationConstants.Exchange.orderStartDisclaimer
                        )
                        
                        self.current.cells = cellModels
                        self.current.footer = footer
                        
                        self.interface?.mostRecentOrderTransaction = orderTransaction
                        self.interface?.mostRecentConversion = conversion
                        
                        self.delegate?.coordinator(self, updated: self.current)
                    })
                disposables.insertWithDiscardableResult(disposable)
            case .locked(let orderTransaction, let conversion):
                logTransactionLocked(orderTransaction)
                
                let destinationCurrency = orderTransaction.destination.balance.currencyType
                
                let disposable = accountRepository.nameOfAccountContaining(
                    address: orderTransaction.destination.address.address,
                    currencyType: destinationCurrency
                    ).asObservable()
                    .take(1)
                    .subscribeOn(MainScheduler.asyncInstance)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self] name in
                        guard let self = self else { return }
                        self.interface?.updateBackgroundColor(.brandPrimary)
                        self.interface?.updateNavigationBar(appearance: NavigationBarAppearanceDark, color: .brandPrimary)
                        self.interface?.updateTitle(LocalizationConstants.Swap.swapLocked)
                        self.interface?.navigationBarVisibility(.hidden)
                        
                        let pair = ExchangeCellModel.TradingPair(
                            model: TradingPairView.confirmationModel(for: conversion)
                        )
                        
                        let value = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.value,
                            value: self.valueString(
                                for: conversion.quote.currencyRatio.counter.fiat.value,
                                currencyCode: conversion.quote.currencyRatio.counter.fiat.symbol
                                ),
                            descriptionAccessibilityId: AccessibilityIdentifier.fiatDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.fiatValueLabel
                        )
                        
                        let fees = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.fees,
                            value: orderTransaction.fees + " " + orderTransaction.from.address.assetType.symbol,
                            descriptionAccessibilityId: AccessibilityIdentifier.feesDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.feesValueLabel
                        )
                        
                        let receive = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.receive,
                            value: orderTransaction.amountToReceive + " " + TradingPair(string: conversion.quote.pair)!.to.symbol,
                            bold: true,
                            descriptionAccessibilityId: AccessibilityIdentifier.receiveDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.receiveValueLabel
                        )
                        
                        let sendTo = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.sendTo,
                            value: name,
                            descriptionAccessibilityId: AccessibilityIdentifier.destinationDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.destinationValueLabel
                        )
                        
                        var orderId = ExchangeCellModel.Plain(
                            description: LocalizationConstants.Exchange.orderID,
                            value: orderTransaction.orderIdentifier ?? "",
                            descriptionAccessibilityId: AccessibilityIdentifier.orderIdDescriptionLabel,
                            valueAccessibilityId: AccessibilityIdentifier.orderIdValueLabel
                        )
                        orderId.descriptionActionBlock = {
                            guard let text = $0.text else { return }
                            UIPasteboard.general.string = text
                            $0.animate(
                                fromText: orderTransaction.orderIdentifier ?? "",
                                toIntermediateText: LocalizationConstants.copiedToClipboard,
                                speed: 1,
                                gestureReceiver: $0
                            )
                        }
                        
                        let footer = ActionableFooterModel(title: LocalizationConstants.Exchange.done)
                        
                        cellModels.append(contentsOf: [
                            .tradingPair(pair),
                            .plain(value),
                            .plain(fees),
                            .plain(receive),
                            .plain(sendTo),
                            .plain(orderId)
                            ]
                        )
                        
                        self.current.header = .locked(.locked)
                        self.current.cells = cellModels
                        self.current.footer = footer
                        
                        self.delegate?.coordinator(self, updated: self.current)
                    })
                disposables.insertWithDiscardableResult(disposable)
            case .overview(let trade):
                interface?.updateBackgroundColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                interface?.updateNavigationBar(
                    appearance: NavigationBarAppearanceDark,
                    color: trade.alertModel != nil ? #colorLiteral(red: 0.41, green: 0.44, blue: 0.52, alpha: 1) : .brandPrimary
                )
                interface?.updateTitle(LocalizationConstants.Exchange.orderID + " " + trade.identifier)
                interface?.navigationBarVisibility(.visible)

                let status = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.status,
                    value: trade.status.displayValue,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    statusVisibility: .visible,
                    statusTintColor: trade.status.tintColor,
                    descriptionAccessibilityId: AccessibilityIdentifier.statusDescriptionLabel,
                    valueAccessibilityId: AccessibilityIdentifier.statusValueLabel
                )

                let value = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.value,
                    value: valueString(for: trade.amountFiatValue, currencyCode: trade.amountFiatSymbol),
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    descriptionAccessibilityId: AccessibilityIdentifier.fiatDescriptionLabel,
                    valueAccessibilityId: AccessibilityIdentifier.fiatValueLabel
                )

                let exchange = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.exchange,
                    value: trade.amountDepositedCrypto,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    descriptionAccessibilityId: AccessibilityIdentifier.cryptoDescriptionLabel,
                    valueAccessibilityId: AccessibilityIdentifier.cryptoValueLabel
                )

                let receive = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.receive,
                    value: trade.amountReceivedCrypto,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    bold: true,
                    descriptionAccessibilityId: AccessibilityIdentifier.receiveDescriptionLabel,
                    valueAccessibilityId: AccessibilityIdentifier.receiveValueLabel
                )
                
                var orderId = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.orderID,
                    value: trade.identifier,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    descriptionAccessibilityId: AccessibilityIdentifier.orderIdDescriptionLabel,
                    valueAccessibilityId: AccessibilityIdentifier.orderIdValueLabel
                )
                orderId.descriptionActionBlock = {
                    guard let text = $0.text else { return }
                    UIPasteboard.general.string = text
                    $0.animate(
                        fromText: trade.identifier,
                        toIntermediateText: LocalizationConstants.copiedToClipboard,
                        speed: 1,
                        gestureReceiver: $0
                    )
                }

                cellModels.append(contentsOf: [
                    .plain(status),
                    .plain(value),
                    .plain(exchange),
                    .plain(receive),
                    .plain(orderId)
                    ]
                )
                
                /// If there's a `alertModel` than there was a problem with the trade.
                /// Only `expired`, `delayed`, `failed`, or `inProgress` trades (that are greater
                /// than 24 hours old) have an `alertModel`.
                /// We used to show a `ActionableFooterModel` but now an alert is shown.
                current.alertModel = trade.alertModel
                current.header = .detail(
                    ExchangeDetailHeaderModel(
                        title: trade.amountReceivedCrypto,
                        backgroundColor: trade.alertModel != nil ? #colorLiteral(red: 0.41, green: 0.44, blue: 0.52, alpha: 1) : .brandPrimary
                    )
                )
                current.cells = cellModels

                delegate?.coordinator(self, updated: current)
                if trade.alertModel != nil {
                    interface?.updateNavigationBar(
                        appearance: NavigationBarAppearanceDark,
                        color: #colorLiteral(red: 0.41, green: 0.44, blue: 0.52, alpha: 1)
                    )
                }
            }
        case .confirmExchange(let transaction):
            AnalyticsService.shared.trackEvent(title: "swap_confirmed")
            
            guard let lastConversion = interface?.mostRecentConversion else {
                Logger.shared.error("No conversion to use")
                return
            }
            guard tradeExecution.isExecuting == false else { return }
            interface?.loadingVisibility(.visible)

            tradeExecution.buildAndSend(
                with: lastConversion,
                from: transaction.from,
                to: transaction.destination,
                success: { [weak self] orderTransaction in
                    guard let this = self else { return }

                    NotificationCenter.default.post(
                        Notification(name: Constants.NotificationKeys.exchangeSubmitted)
                    )
                    
                    this.bus.publish(
                        action: .sendCrypto,
                        extras: [WalletAction.ExtraKeys.assetType: transaction.from.address.assetType]
                    )
                    this.interface?.loadingVisibility(.hidden)
                    ExchangeCoordinator.shared.handle(
                        event: .sentTransaction(
                            orderTransaction: orderTransaction,
                            conversion: lastConversion
                        )
                    )
                    this.delegate?.coordinator(this, completedTransaction: transaction)
            }) { [weak self] errorDescription, transactionID, nabuError in
                guard let this = self else { return }
                let complete: () -> Void = { [weak self] in
                    guard let this = self else { return }
                    if let networkError = nabuError {
                        this.showAlertFrom(networkError)
                    } else {
                        this.interface?.loadingVisibility(.hidden)
                        var description = errorDescription
                        if transaction.from.address.assetType == .stellar {
                            description = LocalizationConstants.Stellar.cannotSendXLMAtThisTime
                        }
                        AlertViewPresenter.shared.standardError(message: description)
                    }
                }
                
                if let identifier = transactionID {
                    this.logTransactionFailure(transaction, errorMessage: errorDescription)
                    this.tradeExecution.trackTransactionFailure(errorDescription, transactionID: identifier, completion: { error in
                        if let value = error {
                            Logger.shared.error(value.localizedDescription)
                        }
                        complete()
                    })
                } else {
                    complete()
                }
            }
        }
    }
    
    fileprivate func logTransactionFailure(_ orderTransaction: OrderTransaction, errorMessage: String) {
        /// We want to make sure we have the latest balance
        /// in the event of a failure, in case there was a discrepancy between
        /// the balance reflected in the `OrderTransaction` and the user's actual
        /// balance. 
        let disposable = accountRepository.defaultAccount(
            for: orderTransaction.from.address.assetType,
            fromCache: false
        )
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { account in
                let balance = account.balance
                AnalyticsService.shared.trackEvent(
                    title: "swap_failure",
                    parameters: [
                        "balance": balance.toDisplayString(includeSymbol: true),
                        "assetType": orderTransaction.from.address.assetType.description,
                        "amount_to_send": orderTransaction.amountToSend,
                        "amount_to_receive": orderTransaction.amountToReceive,
                        "fees": orderTransaction.fees,
                        "error_message": errorMessage,
                        "order_identifier": orderTransaction.orderIdentifier ?? "unknown"
                    ])
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    fileprivate func logTransactionLocked(_ orderTransaction: OrderTransaction) {
        let balance = orderTransaction.from.balance
        AnalyticsService.shared.trackEvent(
            title: "swap_locked",
            parameters: [
                "balance": balance.toDisplayString(includeSymbol: true),
                "assetType": orderTransaction.from.address.assetType.description,
                "amount_to_send": orderTransaction.amountToSend,
                "amount_to_receive": orderTransaction.amountToReceive,
                "fees": orderTransaction.fees,
                "order_identifier": orderTransaction.orderIdentifier ?? "unknown"
            ])
    }
}

extension ExchangeDetailCoordinator {
    
    fileprivate func showAlertFrom(_ nabuError: NabuNetworkError) {
        let min = minTradingLimit().asObservable()
        let max = maxTradingLimit().asObservable()
        let daily = dailyAvailable().asObservable()
        let annual = annualAvailable().asObservable()
        
        let disposable = Observable.zip(min, max, daily, annual)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] payload in
                guard let this = self else { return }
                let code = this.fiatCurrencyCode
                let minValue = FiatValue.create(amount: payload.0, currencyCode: code)
                let maxValue = FiatValue.create(amount: payload.1, currencyCode: code)
                let dailyValue = FiatValue.create(amount: payload.2 ?? 0, currencyCode: code)
                let annualValue = FiatValue.create(amount: payload.3 ?? 0, currencyCode: code)
                
                var alert: AlertModel
                switch nabuError.code {
                case .orderBelowMinLimit:
                    alert = this.belowMinimumAlert(minValue)
                case .orderAboveMaxLimit:
                    alert = this.aboveMaximumAlert(maxValue)
                case .dailyLimitExceeded:
                    alert = this.aboveDailyAlert(dailyValue)
                case .weeklyLimitExceeded,
                     .annualLimitExceeded:
                    alert = this.aboveAnnualAlert(annualValue)
                case .internalServerError:
                    alert = this.albertErrorAlert()
                default:
                    alert = this.albertErrorAlert()
                }
                this.current.footer = nil
                this.current.alertModel = alert
                this.delegate?.coordinator(this, updated: this.current)
            }, onError: { error in
                AlertViewPresenter.shared.standardError(message: error.localizedDescription)
            }, onDisposed: { [weak self] in
                guard let this = self else { return }
                this.interface?.loadingVisibility(.hidden)
            })
        
        disposables.insertWithDiscardableResult(disposable)
    }
    
    // MARK: AlertModel
    
    fileprivate func belowMinimumAlert(_ value: FiatValue) -> AlertModel {
        let body = LocalizationConstants.Exchange.marketMovementMinimum + " " + value.toDisplayString()
        return AlertModel(
            headline: LocalizationConstants.Exchange.marketsMoving,
            body: body,
            actions: [updateOrderAction(), moreInfoAction()],
            style: .sheet
        )
    }
    
    fileprivate func aboveMaximumAlert(_ value: FiatValue) -> AlertModel {
        let body = LocalizationConstants.Exchange.marketMovementMaximum + " " + value.toDisplayString()
        return AlertModel(
            headline: LocalizationConstants.Exchange.marketsMoving,
            body: body,
            actions: [updateOrderAction(), moreInfoAction()],
            style: .sheet
        )
    }
    
    fileprivate func aboveDailyAlert(_ value: FiatValue) -> AlertModel {
        let body = LocalizationConstants.Exchange.dailyAnnualLimitExceeded + " " + value.toDisplayString()
        return AlertModel(
            headline: LocalizationConstants.Exchange.holdHorses,
            body: body,
            actions: [updateOrderAction(), moreInfoAction()],
            style: .sheet
        )
    }
    
    fileprivate func aboveAnnualAlert(_ value: FiatValue) -> AlertModel {
        let body = LocalizationConstants.Exchange.dailyAnnualLimitExceeded + " " + value.toDisplayString()
        return AlertModel(
            headline: LocalizationConstants.Exchange.holdHorses,
            body: body,
            actions: [updateOrderAction(), increaseLimitsAction()],
            style: .sheet
        )
    }
    
    fileprivate func aboveBalanceAlert(_ value: FiatValue) -> AlertModel {
        return AlertModel(
            headline: LocalizationConstants.Exchange.marketsMoving,
            body: LocalizationConstants.Exchange.marketMovementMaximum,
            actions: [updateOrderAction(), moreInfoAction()],
            style: .sheet
        )
    }
    
    fileprivate func albertErrorAlert() -> AlertModel {
        return AlertModel(
            headline: LocalizationConstants.Exchange.oopsSomethingWentWrong,
            body: LocalizationConstants.Exchange.oopsSwapDescription,
            actions: [tryAgainAction()],
            style: .sheet
        )
    }
    
    // MARK: AlertActions
    
    fileprivate func updateOrderAction() -> AlertAction {
        return AlertAction(
            style: .confirm(LocalizationConstants.Exchange.updateOrder),
            metadata: .pop
        )
    }
    
    fileprivate func moreInfoAction() -> AlertAction {
        let url = URL(string: "https://support.blockchain.com/hc/en-us/articles/360023819571-Order-exceeds-wallet-balance")!
        return AlertAction(
            style: .default(LocalizationConstants.Exchange.moreInfo),
            metadata: .url(url)
        )
    }
    
    fileprivate func increaseLimitsAction() -> AlertAction {
        return AlertAction(
            style: .default(LocalizationConstants.Exchange.increaseMyLimits),
            metadata: .block({ [weak self] in
                guard let this = self else { return }
                this.interface?.presentTiers()
            })
        )
    }
    
    fileprivate func tryAgainAction() -> AlertAction {
        return AlertAction(
            style: .confirm(LocalizationConstants.Exchange.tryAgain),
            metadata: .block({ [weak self] in
                guard let this = self else { return }
                guard case let .confirm(transaction, _) = this.current.pageType else { return }
                /// Not ideal but, this will be addressed when this is refactored.
                /// If the user tries to submit their trade again, the model shouldn't reflect that
                /// there's an error. If it does, the view will not receive conversion updates.
                this.current.alertModel = nil
                this.handle(event: .confirmExchange(transaction))
            })
        )
    }
}

// MARK: TradeLimits

extension ExchangeDetailCoordinator {
    fileprivate func tradingLimitInfo(info: @escaping (TradeLimits) -> Decimal) -> Maybe<Decimal> {
        return tradeLimitsService.getTradeLimits(
            withFiatCurrency: fiatCurrencyCode,
            ignoringCache: false).map { tradingLimits -> Decimal in
                return info(tradingLimits)
            }.asMaybe()
    }
    
    fileprivate func minTradingLimit() -> Maybe<Decimal> {
        return tradingLimitInfo(info: { tradingLimits -> Decimal in
            return tradingLimits.minOrder
        })
    }
    
    fileprivate func maxTradingLimit() -> Maybe<Decimal> {
        return tradingLimitInfo(info: { tradingLimits -> Decimal in
            return tradingLimits.maxPossibleOrder
        })
    }
    
    fileprivate func dailyAvailable() -> Maybe<Decimal?> {
        return tradeLimitsService.getTradeLimits(
            withFiatCurrency: fiatCurrencyCode,
            ignoringCache: false).asMaybe().map { limits -> Decimal? in
                return limits.daily?.available
        }
    }
    
    fileprivate func annualAvailable() -> Maybe<Decimal?> {
        return tradeLimitsService.getTradeLimits(
            withFiatCurrency: fiatCurrencyCode,
            ignoringCache: false).asMaybe().map { limits -> Decimal? in
                return limits.annual?.available
        }
    }
}

extension ExchangeDetailCoordinator {
    // TICKET: IOS-1328 Find a better place for this
    func valueString(for amount: String, currencyCode: String) -> String {
        if let currencySymbol =  BlockchainSettings.sharedAppInstance().fiatSymbolFromCode(currencyCode: currencyCode) {
            // $2.34
            // `Partner` models already have the currency symbol appended.
            return amount.contains(currencySymbol) ? amount : currencySymbol + amount
        } else {
            // 2.34 USD
            return amount + " " + currencyCode
        }
    }
}
