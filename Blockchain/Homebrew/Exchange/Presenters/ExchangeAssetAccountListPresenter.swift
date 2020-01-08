//
//  ExchangeAssetAccountListPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import Localization

enum ExchangeAction {
    case exchanging
    case receiving

    var title: String {
        switch self {
        case .exchanging: return LocalizationConstants.Swap.whatDoYouWantToExchange
        case .receiving: return LocalizationConstants.Swap.whatDoYouWantToReceive
        }
    }
}

protocol ExchangeAssetAccountListView: class {
    func showPicker(for assetAccounts: [AssetAccount], action: ExchangeAction)
}

/// A presenter that presents a list of `AssetAccount` that the user can
/// select to exchange crypto into or out of
class ExchangeAssetAccountListPresenter {

    private weak var view: ExchangeAssetAccountListView?
    private let assetAccountRepository: AssetAccountRepository
    private let disposables = CompositeDisposable()

    init(
        view: ExchangeAssetAccountListView,
        assetAccountRepository: AssetAccountRepository = AssetAccountRepository.shared
    ) {
        self.view = view
        self.assetAccountRepository = assetAccountRepository
    }

    func presentPicker(excludingAccount assetAccount: AssetAccount?, for action: ExchangeAction) {
        let disposable = assetAccountRepository.accounts
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] accounts in
                guard let self = self else { return }
                let available = accounts.filter({ $0 != assetAccount })
                self.view?.showPicker(for: available, action: action)
            })
        disposables.insertWithDiscardableResult(disposable)
    }
}
