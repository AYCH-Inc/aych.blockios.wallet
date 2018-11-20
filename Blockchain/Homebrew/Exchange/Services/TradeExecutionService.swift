//
//  TradeExecutionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class TradeExecutionService: TradeExecutionAPI {
    
    // MARK: Models
    
    struct XLMDependencies {
        let accounts: StellarAccountAPI
        let transactionAPI: StellarTransactionAPI
        let ledgerAPI: StellarLedgerAPI
        let repository: WalletXlmAccountRepository
        
        init(xlm: XLMServiceProvider = XLMServiceProvider.shared) {
            transactionAPI = xlm.services.transaction
            ledgerAPI = xlm.services.ledger
            repository = xlm.services.repository
            accounts = xlm.services.accounts
        }
    }
    
    struct Dependencies {
        let assetAccountRepository: AssetAccountRepository
        let xlm: XLMDependencies
        
        init(
            repository: AssetAccountRepository = AssetAccountRepository.shared,
            xlmServiceProvider: XLMServiceProvider = XLMServiceProvider.shared
            ) {
            assetAccountRepository = repository
            xlm = XLMDependencies(xlm: xlmServiceProvider)
        }
    }
    
    private struct PathComponents {
        let components: [String]
        
        static let trades = PathComponents(
            components: ["trades"]
        )
    }
    
    // MARK: Private Properties
    
    private let authentication: NabuAuthenticationService
    private let wallet: Wallet
    private let assetAccountRepository: AssetAccountRepository
    private let dependencies: Dependencies
    private var disposable: Disposable?
    private var pendingXlmPaymentOperation: StellarPaymentOperation?
    
    // MARK: TradeExecutionAPI
    
    var isExecuting: Bool = false
    
    func canTradeAssetType(_ assetType: AssetType) -> Bool {
        switch assetType {
        case .ethereum:
            return !wallet.isWaitingOnEtherTransaction()
        default:
            return true
        }
    }
    
    func validateVolume(_ volume: Decimal, for assetType: AssetType) -> TradeExecutionAPIError? {
        /// The only supported asset type for this function is `.stellar`
        /// This is because stellar has minimum account balance requirements.
        guard assetType == .stellar else { return nil }
        guard let ledger = dependencies.xlm.ledgerAPI.currentLedger else { return .generic }
        guard let stellarAccount = dependencies.xlm.accounts.currentAccount else { return .generic }
        guard let baseReserveInXLM = ledger.baseReserveInXlm else { return .generic }
        
        let minimumBalance = (2.0 + Decimal(stellarAccount.subentryCount)) * baseReserveInXLM
        
        guard let fee = ledger.baseFeeInXlm else { return .generic }
        guard let assetAccount = dependencies.assetAccountRepository.defaultStellarAccount() else { return .generic }
        let delta = assetAccount.balance - (volume + fee)
        if delta < minimumBalance {
            let maxSpendable = assetAccount.balance - fee - minimumBalance
            let value = "\(maxSpendable) " + assetType.symbol
            let description = LocalizationConstants.Stellar.notEnoughXLM + " " + LocalizationConstants.Exchange.yourSpendableBalance
            let result = description + " " + value
            return .exceededMaxVolume(result)
        }
        
        return nil
    }
    
    // MARK: Init
    
    init(
        service: NabuAuthenticationService = NabuAuthenticationService.shared,
        wallet: Wallet = WalletManager.shared.wallet,
        dependencies: Dependencies
        ) {
        self.authentication = service
        self.wallet = wallet
        self.dependencies = dependencies
        self.assetAccountRepository = dependencies.assetAccountRepository
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: - Main Functions

    // Pre-build an order with Exchange information to get fee information.
    // The result of this method is used for display purposes.
    // Do not use this for actually building an order to send - use
    // buildAndSend(with conversion...) instead.
    func prebuildOrder(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((String) -> Void)
    ) {
        guard let pair = TradingPair(string: conversion.quote.pair) else {
            error(LocalizationConstants.Exchange.tradeExecutionError)
            Logger.shared.error("Invalid pair returned from server: \(conversion.quote.pair)")
            return
        }
        guard pair.from == from.address.assetType,
            pair.to == to.address.assetType else {
                error(LocalizationConstants.Exchange.tradeExecutionError)
                Logger.shared.error("Asset types don't match.")
                return
        }
        // This is not the real 'to' address because an order has not been submitted yet
        // but this placeholder is needed to build the payment so that
        // the fees can be returned and displayed by the view.
        let placeholderAddress = from.address.address
        let currencyRatio = conversion.quote.currencyRatio
        let orderTransactionLegacy = OrderTransactionLegacy(
            legacyAssetType: pair.from.legacy,
            from: from.index,
            to: placeholderAddress,
            amount: currencyRatio.base.crypto.value,
            fees: nil
        )
        let createOrderCompletion: ((OrderTransactionLegacy) -> Void) = { orderTransactionLegacy in
            let orderTransactionTo = AssetAddressFactory.create(
                fromAddressString: orderTransactionLegacy.to,
                assetType: AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
            )
            let orderTransaction = OrderTransaction(
                orderIdentifier: "",
                destination: to,
                from: from,
                to: orderTransactionTo,
                amountToSend: orderTransactionLegacy.amount,
                amountToReceive: currencyRatio.counter.crypto.value,
                fees: orderTransactionLegacy.fees!
            )
            success(orderTransaction, conversion)
        }
        buildOrder(from: orderTransactionLegacy, success: createOrderCompletion, error: error)
    }

    // Build an order from an OrderTransactionLegacy struct.
    // OrderTransactionLegacy is a representation of a regular payment object
    // that has no Exchange information.
    fileprivate func buildOrder(
        from orderTransactionLegacy: OrderTransactionLegacy,
        success: @escaping ((OrderTransactionLegacy) -> Void),
        error: @escaping ((String) -> Void),
        memo: String? = nil // TODO: IOS-1291 Remove and separate
    ) {
        let assetType = AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
        let createOrderPaymentSuccess: ((String) -> Void) = { fees in
            if assetType == .bitcoin || assetType == .bitcoinCash {
                // TICKET: IOS-1395 - Use a helper method for this
                let feeInSatoshi = CUnsignedLongLong(truncating: NSDecimalNumber(string: fees))
                orderTransactionLegacy.fees = NumberFormatter.satoshi(toBTC: feeInSatoshi)
            } else {
                orderTransactionLegacy.fees = fees
            }
            success(orderTransactionLegacy)
        }

        // TICKET: IOS-1550 Move this to a different service
        if assetType == .stellar {
            guard let sourceAccount = dependencies.xlm.repository.defaultAccount,
            let ledger = dependencies.xlm.ledgerAPI.currentLedger,
            let fee = ledger.baseFeeInXlm,
            let amount = Decimal(string: orderTransactionLegacy.amount) else { return }
            
            var paymentMemo: StellarMemoType?
            if let value = memo {
                paymentMemo = .text(value)
            }

            pendingXlmPaymentOperation = StellarPaymentOperation(
                destinationAccountId: orderTransactionLegacy.to,
                amountInXlm: amount,
                sourceAccount: sourceAccount,
                feeInXlm: fee,
                memo: paymentMemo
            )
            createOrderPaymentSuccess("\(fee)")
        } else {
            wallet.createOrderPayment(
                withOrderTransaction: orderTransactionLegacy,
                completion: { [weak self] in
                    guard let this = self else { return }
                    this.isExecuting = false
                },
                success: createOrderPaymentSuccess,
                error: error
            )
        }
    }

    // Post a trade to the server. This will create a trade object that will
    // be seen in the ExchangeListViewController.
    fileprivate func process(order: Order) -> Single<OrderResult> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(TradeExecutionAPIError.generic)
        }

        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: PathComponents.trades.components,
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }

        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.POST(
                url: endpoint,
                body: try? JSONEncoder().encode(order),
                token: token.token,
                type: OrderResult.self
            )
        }
    }

    // Sign and send the payment object created by either of the buildOrder methods.
    fileprivate func sendTransaction(
        assetType: AssetType,
        secondPassword: String?,
        success: @escaping (() -> Void),
        error: @escaping ((String) -> Void)
    ) {
        let executionDone = { [weak self] in
            guard let this = self else { return }
            this.isExecuting = false
        }
        if assetType == .stellar {
            guard let paymentOperation = pendingXlmPaymentOperation else {
                Logger.shared.error("No pending payment operation found")
                return
            }
            
            let transaction = dependencies.xlm.transactionAPI
            disposable = dependencies.xlm.repository.loadStellarKeyPair()
                .asObservable().flatMap { keyPair -> Completable in
                    return transaction.send(paymentOperation, sourceKeyPair: keyPair)
                }.subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onError: { paymentError in
                    executionDone()
                    Logger.shared.error("Failed to send XLM. Error: \(paymentError)")
                    if let operationError = paymentError as? StellarPaymentOperationError,
                        operationError == .cancelled {
                        // User cancelled transaction when shown second password - do not show an error.
                        return
                    }
                    error(LocalizationConstants.Stellar.cannotSendXLMAtThisTime)
                }, onCompleted: success)
        } else {
            isExecuting = true
            wallet.sendOrderTransaction(
                assetType.legacy,
                secondPassword: secondPassword,
                completion: executionDone,
                success: success,
                error: error,
                cancel: executionDone
            )
        }
    }
}

// Private Helper methods
fileprivate extension TradeExecutionService {
    // Method for combining process and build order.
    // Called by buildAndSend(with conversion...)
    //
    // TICKET: IOS-1291 Refactor this
    // swiftlint:disable function_body_length
    func processAndBuildOrder(
        with conversion: Conversion,
        fromAccount: AssetAccount,
        toAccount: AssetAccount,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((String) -> Void)
    ) {
        isExecuting = true
        let conversionQuote = conversion.quote
        #if DEBUG
        let settings = DebugSettings.shared
        if settings.mockExchangeDeposit {
            settings.mockExchangeDepositQuantity = conversionQuote.fix == .base ||
                conversionQuote.fix == .baseInFiat ?
                    conversionQuote.currencyRatio.base.crypto.value :
                conversionQuote.currencyRatio.counter.crypto.value
            settings.mockExchangeDepositAssetTypeString = TradingPair(string: conversionQuote.pair)!.from.symbol
        }
        #endif
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let time = dateFormatter.string(from: Date())
        let quote = Quote(
            time: time,
            pair: conversionQuote.pair,
            fiatCurrency: conversionQuote.fiatCurrency,
            fix: conversionQuote.fix,
            volume: conversionQuote.volume,
            currencyRatio: conversionQuote.currencyRatio
        )
        let refundAddress = getReceiveAddress(for: fromAccount.index, assetType: fromAccount.address.assetType)
        let destinationAddress = getReceiveAddress(for: toAccount.index, assetType: toAccount.address.assetType)
        let order = Order(
            destinationAddress: destinationAddress!,
            refundAddress: refundAddress!,
            quote: quote
        )
        disposable = process(order: order)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] payload in
                guard let this = self else { return }
                // Here we should have an OrderResult object, with a deposit address.
                // Fees must be fetched from wallet payment APIs
                let createOrderCompletion: ((OrderTransactionLegacy) -> Void) = { orderTransactionLegacy in
                    let assetType = AssetType.from(legacyAssetType: orderTransactionLegacy.legacyAssetType)
                    let to = AssetAddressFactory.create(fromAddressString: orderTransactionLegacy.to, assetType: assetType)
                    let orderTransaction = OrderTransaction(
                        orderIdentifier: payload.id,
                        destination: toAccount,
                        from: fromAccount,
                        to: to,
                        amountToSend: orderTransactionLegacy.amount,
                        amountToReceive: payload.withdrawal.value,
                        fees: orderTransactionLegacy.fees!
                    )
                    success(orderTransaction, conversion)
                }
                this.buildOrder(from: payload, fromAccount: fromAccount, success: createOrderCompletion, error: error)
            }, onError: { [weak self] requestError in
                guard let this = self else { return }
                this.isExecuting = false
                guard let httpRequestError = requestError as? HTTPRequestError else {
                    error(requestError.localizedDescription)
                    return
                }
                error(httpRequestError.debugDescription)
            })
    }
    // swiftlint:enable function_body_length

    // Private helper method for building an order from an OrderResult struct (returned from the trades endpoint).
    // This method is called by the processAndBuildOrder(with conversion...) method
    // and calls buildOrder(from orderTransactionLegacy...)
    func buildOrder(
        from orderResult: OrderResult,
        fromAccount: AssetAccount,
        success: @escaping ((OrderTransactionLegacy) -> Void),
        error: @escaping ((String) -> Void)
        ) {
        #if DEBUG
        let settings = DebugSettings.shared
        let depositAddress = settings.mockExchangeOrderDepositAddress ?? orderResult.depositAddress
        let depositQuantity = settings.mockExchangeDeposit ? settings.mockExchangeDepositQuantity! : orderResult.deposit.value
        let assetType = settings.mockExchangeDeposit ?
            AssetType(stringValue: settings.mockExchangeDepositAssetTypeString!)!
            : TradingPair(string: orderResult.pair)!.from
        #else
        let depositAddress = orderResult.depositAddress
        let depositQuantity = orderResult.deposit.value
        let pair = TradingPair(string: orderResult.pair)
        let assetType = pair!.from
        #endif
        guard assetType == fromAccount.address.assetType else {
            error("AssetType from fromAccount and AssetType from OrderResult do not match")
            return
        }
        let orderTransactionLegacy = OrderTransactionLegacy(
            legacyAssetType: fromAccount.address.assetType.legacy,
            from: fromAccount.index,
            to: depositAddress,
            amount: depositQuantity,
            fees: nil
        )
        buildOrder(from: orderTransactionLegacy, success: success, error: error, memo: orderResult.depositMemo)
    }
}

// TradeExecutionAPI Helper Functions
extension TradeExecutionService {
    // Public helper method for combining processAndBuildOrder and sendTransaction.
    // Used as the final step to convert Exchange information into built payment
    // and immediately sending the order.
    func buildAndSend(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping ((OrderTransaction) -> Void),
        error: @escaping ((String) -> Void)
    ) {
        let processAndBuild: ((String?) -> ()) = { [weak self] secondPassword in
            guard let this = self else { return }
            this.processAndBuildOrder(
                with: conversion,
                fromAccount: from,
                toAccount: to,
                success: { [weak self] orderTransaction, _ in
                    guard let this = self else { return }
                    this.sendTransaction(
                        assetType: orderTransaction.to.assetType,
                        secondPassword: secondPassword,
                        success: {
                            success(orderTransaction)
                        },
                        error: error
                    )
                },
                error: error
            )
        }

        // Second password must be prompted before an order is processed since it is
        // a cancellable action - otherwise an order will be created even if cancelling
        // second password
        if wallet.needsSecondPassword() && from.address.assetType != .stellar {
            AuthenticationCoordinator.shared.showPasswordConfirm(
                withDisplayText: LocalizationConstants.Authentication.secondPasswordDefaultDescription,
                headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                validateSecondPassword: true,
                confirmHandler: { (secondPass) in
                    processAndBuild(secondPass)
                }
            )
        } else {
            processAndBuild(nil)
        }

    }
}

private extension TradeExecutionService {
    func getReceiveAddress(for account: Int32, assetType: AssetType) -> String? {
        if assetType == .stellar {
            return assetAccountRepository.defaultStellarAccount()?.address.address
        }
        return wallet.getReceiveAddress(forAccount: account, assetType: assetType.legacy)
    }
}
