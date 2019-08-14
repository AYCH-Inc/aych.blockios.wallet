//
//  KYCCountrySelectionPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

/// Protocol definition for the country selection view during the KYC flow
protocol KYCCountrySelectionView: class {

    /// Method invoked once the user selects a native KYC-supported country
    func continueKycFlow(country: KYCCountry)

    /// Method invoked when the user selects a country that is not supported
    /// for exchanging crypto-to-crypto
    func showExchangeNotAvailable(country: KYCCountry)
}

class KYCCountrySelectionPresenter {

    // MARK: - Private Properties

    private let interactor: KYCCountrySelectionInteractor
    private let wallet: Wallet
    private weak var view: KYCCountrySelectionView?
    private let disposables = CompositeDisposable()

    // MARK: - Initializer

    init(
        view: KYCCountrySelectionView,
        interactor: KYCCountrySelectionInteractor = KYCCountrySelectionInteractor(),
        wallet: Wallet = WalletManager.shared.wallet
    ) {
        self.view = view
        self.interactor = interactor
        self.wallet = wallet
    }

    deinit {
        disposables.dispose()
    }

    // MARK: - Public Methods

    func selected(country: KYCCountry) {

        // Notify server of user's selection
        let interactorDisposable = interactor.selected(country: country)
        _ = disposables.insert(interactorDisposable)

        // There are 3 scenarios once a user picks a country:

        // 1. if the country is supported by our native KYC OR if the country has states, proceed
        if country.isKycSupported || country.states.count != 0 {
            Logger.shared.info("Selected country is supported by our native KYC.")
            view?.continueKycFlow(country: country)
            return
        }
        
        view?.showExchangeNotAvailable(country: country)
    }
}
