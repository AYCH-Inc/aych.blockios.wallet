//
//  EmailAuthorizationPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class EmailAuthorizationPresenter {
    
    var isWaitingForEmailValidation = false
    
    // MARK: - Services
    
    private let service: EmailAuthorizationServiceAPI
    private let alertPresenter: AlertViewPresenter
        
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(service: EmailAuthorizationServiceAPI = EmailAuthorizationService(),
         alertPresenter: AlertViewPresenter = .shared) {
        self.service = service
        self.alertPresenter = alertPresenter
    }
    
    func authorize(_ completion: @escaping () -> Void) {
        service.authorize
            .subscribe(
                onCompleted: {
                    completion()
                },
                onError: { error in
                    print("BOO: \(error)")
                }
            )
            .disposed(by: disposeBag)
        
        isWaitingForEmailValidation = true
        alertPresenter.showEmailAuthorizationRequired { [weak self] in
            self?.isWaitingForEmailValidation = false
        }
    }
}
