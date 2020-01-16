//
//  AddressPreseterTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

@testable import Blockchain

class AddressPresenterTests: XCTestCase {
    
    func testAddressPresenterStatus() {
        let asset = AssetType.ethereum
        let addressString = "eth-address"
        let address = WalletAddressContent(string: addressString, image: UIImage())
        let payment = ReceivedPaymentDetails(amount: "1 ETH", asset: asset, address: addressString)
        let interactor = AddressInteractorMock(asset: asset,
                                               address: address,
                                               receivedPayment: payment)
        let pasteboard = MockPasteboard()
        let presenter = AddressPresenter(interactor: interactor,
                                         pasteboard: pasteboard)
        
        let statusBlocking = presenter.status.toBlocking()
        
        XCTAssertEqual(try statusBlocking.first(), .awaitingFetch)
        
        presenter.fetchAddress()
        XCTAssertEqual(try statusBlocking.first(), .readyForDisplay(content: address))        
    }
}
