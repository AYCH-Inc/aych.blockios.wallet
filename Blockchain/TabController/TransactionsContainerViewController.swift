//
//  TransactionsContainerViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class TransactionsContainerViewController: UIViewController {
    
    private lazy var bitcoinVC: TransactionsBitcoinViewController = {
        return Bundle.main.loadNibNamed("Transactions", owner: self, options: nil)!.first as! TransactionsBitcoinViewController
    }()
    
    private lazy var etherVC = TransactionsEthereumViewController()
    private lazy var bitcoinCashVC = TransactionsBitcoinCashViewController()
    private lazy var stellarVC = TransactionsXlmViewController.make(with: .shared)
    private lazy var paxVC = PaxActivityViewController.make()
    
    private weak var currentVC: UIViewController!
    
    func set(asset: AssetType) {
        currentVC?.remove()
        switch asset {
        case .bitcoin:
            currentVC = bitcoinVC
        case .bitcoinCash:
            currentVC = bitcoinCashVC
        case .stellar:
            currentVC = stellarVC
        case .ethereum:
            currentVC = etherVC
        case .pax:
            currentVC = paxVC
        }
        add(child: currentVC)
    }
}
