//
//  SendXLMCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class SendXLMCoordinator {
    fileprivate let serviceProvider: XLMServiceProvider
    fileprivate let interface: SendXLMInterface
    fileprivate let modelInterface: SendXLMModelInterface
    fileprivate let disposables = CompositeDisposable()
    fileprivate var services: XLMServices {
        return serviceProvider.services
    }

    init(
        serviceProvider: XLMServiceProvider,
        interface: SendXLMInterface,
        modelInterface: SendXLMModelInterface
    ) {
        self.serviceProvider = serviceProvider
        self.interface = interface
        self.modelInterface = modelInterface
        if let controller = interface as? SendLumensViewController {
            controller.delegate = self
        }
    }

    deinit {
        disposables.dispose()
    }
    
    enum InternalEvent {
        case insufficientFunds
        case noStellarAccount
        case noXLMAccount
    }
    
    // MARK: Private Functions

    fileprivate func accountDetailsTrigger() -> Observable<StellarAccount> {
        return services.operation.operations.concatMap { result -> Observable<StellarAccount> in
            return self.services.accounts.currentStellarAccount(fromCache: false).asObservable()
        }
    }
    
    fileprivate func observeOperations() {
        let disposable = Observable.combineLatest(accountDetailsTrigger(), services.ledger.current)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (account, ledger) in
                // TODO:
            }, onError: { error in
                guard let serviceError = error as? StellarServiceError else { return }
                Logger.shared.error(error.localizedDescription)
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    fileprivate func handle(internalEvent: InternalEvent) {
        switch internalEvent {
        case .insufficientFunds:
            // TODO
            break
        case .noStellarAccount,
             .noXLMAccount:
            let trigger = ActionableTrigger(text: "Minimum of", CTA: "1 XLM", secondary: "needed for new accounts.") {
                // TODO: On `1 XLM` selection, show the minimum balance screen.
            }
            let ledger = services.ledger.current
            interface.apply(updates: [.actionableLabelTrigger(trigger),
                                      .fiatFieldTextColor(.error),
                                      .xlmFieldTextColor(.error),
                                      .errorLabelVisibility(.hidden),
                                      .feeAmountLabelText()])
            break
        }
    }
    
}

extension SendXLMCoordinator: SendXLMViewControllerDelegate {
    func onLoad() {
        // TODO: Users may have a `defaultAccount` but that doesn't mean
        // that they have an `StellarAccount` as it must be funded.
        let disposable = services.accounts.currentStellarAccount(fromCache: true).asObservable()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { account in
                /// The user has a StellarAccount, we should enable the input fields.
                /// Begin observing operations and updating the user account.
                self.observeOperations()
            }, onError: { [weak self] error in
                guard let this = self else { return }
                guard let serviceError = error as? StellarServiceError else { return }
                switch serviceError {
                case .noXLMAccount:
                    this.handle(internalEvent: .noXLMAccount)
                case .noDefaultAccount:
                    this.handle(internalEvent: .noStellarAccount)
                default:
                    break
                }
                this.handle(internalEvent: .insufficientFunds)
                Logger.shared.error(error.localizedDescription)
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    func onAppear() {
        let fiatSymbol = BlockchainSettings.sharedAppInstance().fiatCurrencyCode ?? "USD"
        let disposable = Single.zip(services.prices.fiatPrice(forAssetType: .stellar, fiatSymbol: fiatSymbol), services.ledger.current.take(1).asSingle()) {
                return ($0, $1)
            }.subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] price, ledger in
                guard let feeInXlm = ledger.baseFeeInXlm else {
                    Logger.shared.error("Fee is nil.")
                    self.interface.apply(updates: [
                        .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime)
                    ])
                    return
                }
                self.modelInterface.updateFee(feeInXlm)
                self.modelInterface.updatePrice(price.price)
                self.interface.apply(updates: [.feeAmountLabelText()])
            }, onError: { [unowned self] error in
                Logger.shared.error(error.localizedDescription)
                self.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Errors.genericError)
                ])
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    func onXLMEntry(_ value: String, latestPrice: Decimal) {
        guard let decimal = Decimal(string: value) else { return }
        modelInterface.updateXLMAmount(NSDecimalNumber(string: value).decimalValue)
        let fiat = NSDecimalNumber(decimal: latestPrice).multiplying(by: NSDecimalNumber(decimal: decimal))
        guard let fiatText = NumberFormatter.localCurrencyFormatter.string(from: fiat) else {
            Logger.shared.error("Could not format fiat text")
            return
        }

        interface.apply(updates: [
            .fiatAmountText(fiatText),
            .errorLabelVisibility(.hidden),
            .fiatFieldTextColor(.gray6),
            .xlmFieldTextColor(.gray6)
        ])
    }
    
    func onFiatEntry(_ value: String, latestPrice: Decimal) {
        guard let decimal = Decimal(string: value) else { return }
        let crypto = NSDecimalNumber(decimal: decimal).dividing(by: NSDecimalNumber(decimal: latestPrice))
        modelInterface.updateXLMAmount(crypto.decimalValue)
        guard let cryptoText = NumberFormatter.stellarFormatter.string(from: crypto) else {
            Logger.shared.error("Could not format crypto text")
            return
        }
        interface.apply(updates: [
            .stellarAmountText(cryptoText),
            .errorLabelVisibility(.hidden),
            .fiatFieldTextColor(.gray6),
            .xlmFieldTextColor(.gray6)
        ])
    }
    
    func onSecondaryPasswordValidated() {
        
    }

    func onConfirmPayTapped(_ paymentOperation: StellarPaymentOperation) {
        let transaction = services.transaction
        let disposable = services.repository.loadStellarKeyPair()
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.interface.apply(updates: [
                    .hidePaymentConfirmation,
                    .activityIndicatorVisibility(.visible)
                ])
            })
            .flatMap { keyPair -> Completable in
                return transaction.send(paymentOperation, sourceKeyPair: keyPair)
            }
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                Logger.shared.error("Failed to send XLM. Error: \(error)")
                self?.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime),
                    .activityIndicatorVisibility(.hidden)
                ])
            }, onCompleted: { [weak self] in
                self?.interface.apply(updates: [
                    .paymentSuccess,
                    .activityIndicatorVisibility(.hidden)
                ])
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    func onPrimaryTapped(toAddress: String, amount: Decimal, feeInXlm: Decimal) {
        guard let sourceAccount = services.repository.defaultAccount else {
            interface.apply(updates: [
                .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime)
            ])
            return
        }

        let disposable = services.limits.isSpendable(amount: amount, for: sourceAccount.publicKey)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] isSpendable in
                guard isSpendable else {
                    self?.interface.apply(updates: [
                        .errorLabelText(LocalizationConstants.Stellar.notEnoughXLM),
                        .errorLabelVisibility(.visible),
                        .fiatFieldTextColor(.error),
                        .xlmFieldTextColor(.error)
                    ])
                    return
                }
                let operation = StellarPaymentOperation(
                    destinationAccountId: toAddress,
                    amountInXlm: amount,
                    sourceAccount: sourceAccount,
                    feeInXlm: feeInXlm
                )
                self?.interface.apply(updates: [
                    .showPaymentConfirmation(operation)
                ])
            }, onError: { [weak self] error in
                Logger.shared.error("Could not fetch ledger or account details")
                self?.interface.apply(updates: [
                    .errorLabelText(LocalizationConstants.Stellar.cannotSendXLMAtThisTime)
                ])
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    func onUseMaxTapped() {
        
    }
}
