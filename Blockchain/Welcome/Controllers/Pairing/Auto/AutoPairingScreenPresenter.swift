//
//  AutoPairingScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

/// A presenter for auto pairing screen
final class AutoPairingScreenPresenter {
    
    // MARK: - Properties

    let scannerBuilder: QRCodeScannerViewControllerBuilder<PairingCodeQRCodeParser>
    
    private let loadingViewPresenter: LoadingViewPresenting
    private let alertPresenter: AlertViewPresenter
    private let interactor: AutoPairingScreenInteractor
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: AutoPairingScreenInteractor = AutoPairingScreenInteractor(),
         alertPresenter: AlertViewPresenter = .shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.interactor = interactor
        self.loadingViewPresenter = loadingViewPresenter
        self.alertPresenter = alertPresenter
        scannerBuilder = QRCodeScannerViewControllerBuilder(
            parser: interactor.parser,
            textViewModel: PairingCodeQRCodeTextViewModel(),
            completed: interactor.handlePairingCodeResult
        )
        .with(loadingViewPresenter: loadingViewPresenter, style: .circle)
        .with(presentationType: .child)
     
        interactor.error
            .bind { [weak alertPresenter] error in
                guard let alertPresenter = alertPresenter else { return }
                alertPresenter.standardError(message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
}
