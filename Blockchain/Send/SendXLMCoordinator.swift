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
    fileprivate let disposables = CompositeDisposable()
    fileprivate var services: XLMServices {
        return serviceProvider.services
    }
    
    init(serviceProvider: XLMServiceProvider, interface: SendXLMInterface) {
        self.serviceProvider = serviceProvider
        self.interface = interface
        if let controller = interface as? SendLumensViewController {
            controller.delegate = self
        }
    }

    deinit {
        disposables.dispose()
    }

    fileprivate func accountDetailsTrigger() -> Observable<StellarAccount> {
        return services.operation.operations.concatMap { _ -> Observable<StellarAccount> in
            return self.services.accounts.currentStellarAccount(fromCache: false).asObservable()
        }
    }
    
    fileprivate func observeOperations() {
        let disposable = Observable.combineLatest(accountDetailsTrigger(), services.ledger.current)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (account, ledger) in
                // The users account (and thus balance)
                // may have changed due to an operation.
            }, onError: { error in
                guard let serviceError = error as? StellarServiceError else { return }
                // TODO:
                Logger.shared.error(error.localizedDescription)
            })
        services.operation.start()
        disposables.insertWithDiscardableResult(disposable)
    }
    
}

extension SendXLMCoordinator: SendXLMViewControllerDelegate {
    func onLoad() {
        // TODO: Users may have a `defaultAccount` but that doesn't mean
        // that they have an `StellarAccount` as it must be funded.
        let disposable = services.accounts.currentStellarAccount(fromCache: false).asObservable()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { account in
                /// The user has a StellarAccount, we should enable the input fields.
                /// Begin observing operations and updating the user account.
                self.observeOperations()
            }, onError: { error in
                guard let serviceError = error as? StellarServiceError else { return }
                // TODO:
                Logger.shared.error(error.localizedDescription)
            })
        disposables.insertWithDiscardableResult(disposable)
    }
    
    func onXLMEntry(_ value: String) {
        
    }
    
    func onFiatEntry(_ value: String) {
        
    }
    
    func onSecondaryPasswordValidated() {
        
    }
    
    func onPrimaryTapped() {
        
    }
    
    func onUseMaxTapped() {
        
    }
}
