//
//  EthereumWallet.swift
//  Blockchain
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import EthereumKit
import PlatformKit
import RxSwift

@objc public protocol LegacyEthereumWalletProtocol {
    func getEtherAddress(success: @escaping (String) -> Void, error: @escaping (String?) -> Void)
    func getLabelForAccount(_ account: Int32, assetType: LegacyAssetType) -> String!
    func getEthBalanceTruncatedNumber() -> NSNumber?
    func getEthTransactions() -> [EtherTransaction]?
}

extension Wallet: LegacyEthereumWalletProtocol {}

extension PlatformKit.Direction {
    var txType: EtherTransaction.TxType {
        switch self {
        case .credit:
            return .received
        case .debit:
            return .sent
        case .transfer:
            return .transfer
        }
    }
}

extension EtherTransaction {
    
    enum TxType: String {
        case sent
        case received
        case transfer
        
        var platformDirection: PlatformKit.Direction {
            switch self {
            case .received:
                return .credit
            case .sent:
                return .debit
            case .transfer:
                return .transfer
            }
        }
    }
    
    convenience init(transaction: EthereumTransaction?) {
        self.init()
        
        guard let transaction = transaction else { return }
        
        self.amount = transaction.amount
        self.amountTruncated = EtherTransaction.truncatedAmount(transaction.amount)
        self.fee = CryptoValue
            .etherFromGwei(string: "\(transaction.fee ?? 0)")?
            .toDisplayString(includeSymbol: false)
        self.from = transaction.fromAddress.publicKey
        self.to = transaction.toAddress.publicKey
        self.myHash = transaction.transactionHash
        self.note = transaction.memo
        self.txType = transaction.direction.txType.rawValue
        self.time = UInt64(transaction.createdAt.timeIntervalSince1970)
        self.confirmations = UInt(transaction.confirmations)
        self.fiatAmountsAtTime = [:]
    }
    
    public var transaction: EthereumTransaction? {
        return EtherTransaction.mapToTransaction(self)
    }
    
    public static func mapToTransaction(_ legacyTransaction: EtherTransaction) -> EthereumTransaction? {
        guard let from = legacyTransaction.from,
            let to = legacyTransaction.to,
            let amount = legacyTransaction.amount,
            let myHash = legacyTransaction.myHash,
            let txType = legacyTransaction.txType else {
            return nil
        }
        
        let fromAddress = EthereumAssetAddress(
            publicKey: from
        )
        
        let toAddress = EthereumAssetAddress(
            publicKey:  to
        )
        
        guard let direction = TxType(rawValue: txType)?.platformDirection,
            let f = legacyTransaction.fee else {
            return nil
        }
        
        // Convert from Ether to GWei
        let feeGwei: Int = NSDecimalNumber(string: f)
            .multiplying(
                byPowerOf10: 9,
                withBehavior: NSDecimalNumberHandler(
                    roundingMode: .bankers,
                    scale: 2,
                    raiseOnExactness: true,
                    raiseOnOverflow: true,
                    raiseOnUnderflow: true,
                    raiseOnDivideByZero: true
                )
            )
            .intValue
        
        return EthereumTransaction(
            identifier: myHash,
            fromAddress: fromAddress,
            toAddress: toAddress,
            direction: direction,
            amount: amount,
            transactionHash: myHash,
            createdAt: Date(timeIntervalSince1970: TimeInterval(legacyTransaction.time)),
            fee: feeGwei,
            memo: legacyTransaction.note,
            confirmations: Int(legacyTransaction.confirmations)
        )
    }
}

extension EthereumTransaction {
    var legacyTransaction: EtherTransaction? {
        return EtherTransaction(transaction: self)
    }
}

public class EthereumWallet: NSObject & EthereumWalletBridgeAPI {
    public var balance: Single<CryptoValue> {
        return Single.just(wallet?.getEthBalanceTruncatedNumber())
            .onNil(error: WalletError.notInitialized)
            .flatMap { balance -> PrimitiveSequence<SingleTrait, CryptoValue> in
                let value = CryptoValue.createFromMajorValue(
                    balance.decimalValue,
                    assetType: .ethereum
                )
                return Single.just(value)
            }
    }
    
    public var name: Single<String> {
        // TODO: This value should be read from `wallet.js:EthWallet.defaultAccountIdx()`
        let account: Int32 = 0
        return Single.just(wallet?.getLabelForAccount(account, assetType: .ether))
            .onNil(error: WalletError.notInitialized)
    }
    
    public var address: Single<String> {
        return Single.create(subscribe: { observer -> Disposable in
            self.wallet?.getEtherAddress(success: { address in
                observer(.success(address))
            }, error: { _ in
                observer(.error(WalletError.notInitialized))
            })
            return Disposables.create()
        })
    }
    
    public var transactions: Single<[EthereumTransaction]> {
        return Single.create(subscribe: { [weak self] observer -> Disposable in
            guard let legacyTransactions = self?.wallet?.getEthTransactions() else {
                observer(.error(WalletError.notInitialized))
                return Disposables.create()
            }
            let transactions: [EthereumTransaction] = legacyTransactions
                .map { $0.transaction }
                .compactMap { $0 }
            observer(.success(transactions))
            return Disposables.create()
        })
    }
    
    public var account: Single<EthereumAssetAccount> {
        return Single.zip(address, name)
            .flatMap { accountAddress, name -> Single<EthereumKit.EthereumAssetAccount> in
                let account = EthereumAssetAccount(
                    walletIndex: 0,
                    accountAddress: accountAddress,
                    name: name
                )
                return Single.just(account)
            }
    }
    
    private weak var wallet: LegacyEthereumWalletProtocol?
    
    @objc public init(wallet: LegacyEthereumWalletProtocol) {
        self.wallet = wallet
    }
}
