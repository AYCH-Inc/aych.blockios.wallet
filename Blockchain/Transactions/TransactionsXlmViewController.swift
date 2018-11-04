//
//  TransactionsXlmViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class TransactionsXlmViewController: SimpleTransactionsViewController {
    @objc class func make(with provider: XLMServiceProvider) -> TransactionsXlmViewController {
        let controller = SimpleListViewController.make(
            with: TransactionsXlmViewController.self,
            dataProvider: TransactionsXlmDataProvider.self,
            presenter: TransactionsXlmPresenter.self,
            interactor: TransactionsXlmInteractor(with: provider)
        )
        
        // TODO add xlm balance here
        AppCoordinator.shared.tabControllerManager.tabViewController.updateBalanceLabelText("")
        return controller
    }
    
    override func showItemDetails(item: Identifiable) {
        guard let model = item as? StellarOperation else { return }
        let detailViewController = TransactionDetailViewController()
        let navigation = TransactionDetailNavigationController(rootViewController: detailViewController)
        detailViewController.busyViewDelegate = navigation
        detailViewController.modalTransitionStyle = .coverVertical
        
        if case let .payment(payment) = model {
            let viewModel: TransactionDetailViewModel = TransactionDetailViewModel(xlmTransaction: payment)
            detailViewController.transactionModel = viewModel
            navigation.transactionHash = payment.transactionHash
        }
        
        if case let .accountCreated(created) = model {
            let viewModel: TransactionDetailViewModel = TransactionDetailViewModel(xlmTransaction: created)
            detailViewController.transactionModel = viewModel
            navigation.transactionHash = created.transactionHash
        }
        
        guard let top = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController else { return }
        top.present(navigation, animated: true, completion: nil)
    }
    
    @objc func reload() {
        // TODO add xlm balance here
        AppCoordinator.shared.tabControllerManager.tabViewController.updateBalanceLabelText("")
    }
}
