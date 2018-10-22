//
//  TransactionsXLMViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class TransactionsXLMViewController: SimpleTransactionsViewController {
    @objc class func make() -> TransactionsXLMViewController {
        let controller = SimpleListViewController.make(
            with: TransactionsXLMViewController.self,
            dataProvider: TransactionsXLMDataProvider.self,
            presenter: TransactionsXLMPresenter.self,
            interactor: TransactionsXLMInteractor.self
        )
        return controller
    }
}
