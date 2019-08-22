//
//  SendSourceAccountCellPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

/// Presenter for the source account on the send screen
struct SendSourceAccountCellPresenter {
    
    // MARK: - Properties
        
    /// Returns the account
    var account: Driver<String> {
        return accountRelay.asDriver()
    }
    
    private let interactor: SendSourceAccountInteracting
    
    /// The relay for the account
    private let accountRelay = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: SendSourceAccountInteracting) {
        self.interactor = interactor
        interactor.account
            .map { $0.label }
            .bind(to: accountRelay)
            .disposed(by: disposeBag)
    }
}
