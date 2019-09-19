//
//  WalletProtocol.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
protocol WalletProtocol: class {
    
    var isBitcoinWalletFunded: Bool { get }
    
    @objc var password: String? { get set }
    @objc var isNew: Bool { get set }
    @objc var delegate: WalletDelegate! { get set }
    
    @objc func encrypt(_ data: String, password: String) -> String
    @objc func isInitialized() -> Bool
//    @objc func load(withGuid guid: String!, sharedKey: String!, password: String!)
}
