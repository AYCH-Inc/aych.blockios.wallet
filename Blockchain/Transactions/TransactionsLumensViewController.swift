//
//  TransactionsLumensViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class TransactionsLumensViewController: SimpleTransactionsViewController {
    @objc class func make() -> TransactionsLumensViewController {
        let controller = SimpleListViewController.make(
            with: TransactionsLumensViewController.self,
            dataProvider: TransactionsLumensDataProvider.self,
            presenter: TransactionsLumensPresenter.self,
            interactor: TransactionsLumensInteractor.self
        )
        return controller
    }
}
