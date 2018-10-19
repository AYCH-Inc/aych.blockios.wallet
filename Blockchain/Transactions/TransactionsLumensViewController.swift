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
        let service = StellarTransactionServiceAPI()
        let controller = SimpleListViewController.make(with: service, type: TransactionsLumensViewController.self)
        return controller
    }
}
