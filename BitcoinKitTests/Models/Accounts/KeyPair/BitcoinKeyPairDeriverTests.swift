//
//  BitcoinKeyPairDeriverTests.swift
//  BitcoinKitTests
//
//  Created by Jack on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import TestKit
import HDWalletKit
@testable import BitcoinKit

class BitcoinKeyPairDeriverTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var subject: AnyBitcoinKeyPairDeriver!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        subject = AnyBitcoinKeyPairDeriver()
    }

    override func tearDown() {
        subject = nil
        scheduler = nil
        disposeBag = nil

        super.tearDown()
    }
    
    func test_expected_privateKey() throws {
        
        let expectedPrivateKey = "xprv9s21ZrQH143K3fSXNaonDA6T8ZmP8JUMhTCZKhrFtZCxZX9DddfQ4wsUTWd7HgUPQB7TKg6eicuwWMdpC7TimacYb464NE4YdaaNnCya6e6"
        let expectedPublicKey = "xpub661MyMwAqRbcG9WzUcLnaJ3BgbbsXmCD4g8A86FsStjwSKUNBAyeckBxJoSQUaBe286hzUU7vtDku75jrvVcZ8JMMZfLqDZQV8dzbEDCYeL"
        
        let password = MockWalletTestData.password
        let mnemonic =  MockWalletTestData.mnemonic
        let passphrase = Passphrase(rawValue: password)
        let words = try Words(words: mnemonic)
        let mnemonics = try Mnemonic(words: words, passphrase: passphrase)
        let wallet = try HDWallet(mnemonic: mnemonics, network: .main(Bitcoin.self))
        let key = wallet.privateKey
        
        XCTAssertEqual(key.xpriv!, expectedPrivateKey)
        XCTAssertEqual(key.xpub, expectedPublicKey)
    }
    
    func test_derive() throws {
        // Arrange
        let password = MockWalletTestData.password
        let mnemonic =  MockWalletTestData.mnemonic
        let passphrase = Passphrase(rawValue: password)
        let words = try Words(words: mnemonic.components(separatedBy: " "))
        let mnemonics = try Mnemonic(words: words, passphrase: passphrase)
        let wallet = try HDWallet(mnemonic: mnemonics, network: .main(Bitcoin.self))
        let privateKey = BitcoinPrivateKey(
            key: wallet.privateKey
        )
        
        let expectedKeyPair = BitcoinKeyPair(privateKey: privateKey)
        
        let keyDerivationInput = BitcoinKeyDerivationInput(
            mnemonic: mnemonic,
            password: password
        )

        let deriveObservable = subject
            .derive(input: keyDerivationInput)
            .single
            .asObservable()

        // Act
        let result: TestableObserver<BitcoinKeyPair> = scheduler
            .start { deriveObservable }

        // Assert
        let expectedEvents: [Recorded<Event<BitcoinKeyPair>>] = Recorded.events(
            .next(
                200,
                expectedKeyPair
            ),
            .completed(200)
        )
        XCTAssertEqual(result.events, expectedEvents)
    }


}
