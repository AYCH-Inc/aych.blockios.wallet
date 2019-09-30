//
//  SendDestinationAccountInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

// TODO: - Ether: Write logic that checks if the destination address is a contract address
// [WalletManager.sharedInstance.wallet isEtherContractAddress:address completion:^(NSData *data, NSURLResponse *response, NSError *error) {

/// The destination account interactor on the send screen
final class SendDestinationAccountInteractor: SendDestinationAccountInteracting {
    
    // MARK: - Exposed Properties
    
    /// Streams the state of the destination account
    var accountState: Observable<SendDestinationAccountState> {
        return accountRelay.asObservable()
    }
    
    /// Streams boolean value on whether the source account is connected to the PIT and has a valid PIT address
    var hasPitAccount: Observable<Bool> {
        return Observable
            .combineLatest(pitAccountRelay, isTwoFAConfigurationRequired)
            .map { $0.0.isValid || $0.1 }
            .distinctUntilChanged()
            .asObservable()
    }
    
    /// Streams boolean value indicating whether 2-fa configuration required (used upon tapping the PIT address button)
    var isTwoFAConfigurationRequired: Observable<Bool> {
        return twoFAConfigurationRequiredRelay.asObservable()
    }
        
    /// A relay for PIT address selection
    let pitSelectedRelay = PublishRelay<Bool>()
    
    /// The associated asset
    let asset: AssetType
    
    // MARK: - Private Properties
    
    private let accountRelay = BehaviorRelay<SendDestinationAccountState>(value: .invalid(.empty))
    private let pitAccountRelay = BehaviorRelay<SendDestinationAccountState>(value: .invalid(.empty))
    private let twoFAConfigurationRequiredRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    // MARK: - Services
    
    private let pitAddressFetcher: PitAddressFetching
    private let accountValidator = AccountValidator()
    
    // MARK: - Setup
    
    init(asset: AssetType,
         pitAddressFetcher: PitAddressFetching) {
        self.asset = asset
        self.pitAddressFetcher = pitAddressFetcher
        
        pitAddressFetcher.fetchAddress(for: asset)
            .subscribe(onSuccess: { [weak self] address in
                guard let self = self else { return }
                self.pitAccountRelay.accept(.valid(address: address))
                self.twoFAConfigurationRequiredRelay.accept(false)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                switch error {
                case PitAddressFetcher.FetchingError.twoFactorRequired:
                    self.twoFAConfigurationRequiredRelay.accept(true)
                default:
                    self.pitAccountRelay.accept(.invalid(.fetch))
                }
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(pitSelectedRelay.asObservable(), pitAccountRelay.asObservable())
            .filter { (isSelected, accountState) -> Bool in
                return isSelected
            }
            .map { (_, accountState) -> String? in
                return accountState.addressValue
            }
            .compactMap { $0 }
            .bind { [weak self] address in
                self?.set(address: address)
            }
            .disposed(by: disposeBag)
        
        pitSelectedRelay
            .filter { !$0 }
            .map { _ in SendDestinationAccountState.invalid(.empty) }
            .bind(to: accountRelay)
            .disposed(by: disposeBag)
    }
    
    /// Receives a destination address, validates and then sets it.
    /// - Parameter address: the string representation of the address
    func set(address: String) {
        
        // Make sure the address is not empty
        guard !address.isEmpty else {
            accountRelay.accept(.invalid(.empty))
            return
        }
        
        // Validate the address using a generic address validator
        guard accountValidator.validate(address: address, as: asset) else {
            accountRelay.accept(.invalid(.format))
            return
        }
        
        // Streams a valid state for the destination account
        accountRelay.accept(.valid(address: address))
    }
}
