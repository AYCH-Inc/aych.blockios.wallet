//
//  PaymentsPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 01/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformUIKit

/// Subscribes to payments and presents a confirmation to the user upon receiving them
class PaymentPresenter {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(walletManager: WalletManager = .shared) {
        walletManager.paymentReceived
            .observeOn(MainScheduler.instance)
            .bind { [weak self] payment in
                self?.displayAlert(with: payment)
            }
            .disposed(by: disposeBag)
    }
    
    private func displayAlert(with payment: ReceivedPaymentDetails) {
        let button = AlertAction(style: .confirm(LocalizationConstants.close))
        let title = String(format: LocalizationConstants.PaymentReceivedAlert.titleFormat, payment.asset.description)
        let alert = AlertModel(headline: title,
                               body: payment.amount,
                               actions: [button],
                               image: payment.asset.filledImageLarge,
                               style: .sheet)
        let alertView = AlertView.make(with: alert, completion: nil)
        alertView.show()
    }
}
