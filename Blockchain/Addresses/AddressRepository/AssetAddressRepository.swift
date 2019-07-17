//
//  AssetAddressRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import StellarKit
import PlatformKit
import ERC20Kit
import RxSwift

/// Address usage status
enum AddressUsageStatus {
    
    /// Used address - indicates the address had been used by another transaction
    case used(address: String)
    
    /// Unused address - indicates the address has not been used yet
    case unused(address: String)
    
    /// Unknown usage status - indicates the address usage couldn't be deducted
    case unknown(address: String)
    
    /// Returns `true` if the status is `unused`
    var isUnused: Bool {
        switch self {
        case .unused:
            return true
        case .used, .unknown:
            return false
        }
    }
    
    /// Returns the address associated with the usage status
    var address: String {
        switch self {
        case .unknown(address: let address):
            return address
        case .unused(address: let address):
            return address
        case .used(address: let address):
            return address
        }
    }
}

enum AssetAddressType {
    case swipeToReceive
    case standard
}

/// Repository for asset addresses
@objc class AssetAddressRepository: NSObject, AssetAddressFetching {

    static let shared = AssetAddressRepository()

    /// Accessor for obj-c compatibility
    @objc class func sharedInstance() -> AssetAddressRepository { return shared }

    private let walletManager: WalletManager
    private let stellarWalletAccountRepository: StellarWalletAccountRepository
    private let paxAssetAccountRepository: ERC20AssetAccountRepository<PaxToken>
    
    private let disposeBag = DisposeBag()
    
    init(walletManager: WalletManager = WalletManager.shared,
         stellarWalletRepository: StellarWalletAccountRepository = StellarWalletAccountRepository(with: WalletManager.shared.wallet),
         paxAssetAccountRepository: ERC20AssetAccountRepository<PaxToken> = PAXServiceProvider.shared.services.assetAccountRepository
        ) {
        self.walletManager = walletManager
        self.stellarWalletAccountRepository = stellarWalletRepository
        self.paxAssetAccountRepository = paxAssetAccountRepository
        super.init()
        self.walletManager.swipeAddressDelegate = self
    }

    // TODO: move latest multiaddress response here

    /// Fetches the swipe to receive addresses for all assets if possible
    func fetchSwipeToReceiveAddressesIfNeeded() {

        // Perform guard checks
        let appSettings = BlockchainSettings.App.shared
        guard appSettings.swipeToReceiveEnabled else {
            Logger.shared.info("Swipe to receive is disabled.")
            return
        }

        let wallet = walletManager.wallet

        guard wallet.isInitialized() else {
            Logger.shared.warning("Wallet is not yet initialized.")
            return
        }

        guard wallet.didUpgradeToHd() else {
            Logger.shared.warning("Wallet has not yet been upgraded to HD.")
            return
        }

        // Only one address for ethereum and stellar
        appSettings.swipeAddressForEther = wallet.getEtherAddress()
        appSettings.swipeAddressForStellar = stellarWalletAccountRepository.defaultAccount?.publicKey
        paxAssetAccountRepository.assetAccountDetails.subscribe(onSuccess: { details in
            appSettings.swipeAddressForPax = details.account.accountAddress
        }).disposed(by: disposeBag)
        
        // Retrieve swipe addresses for bitcoin and bitcoin cash
        let assetTypesWithHDAddresses = [AssetType.bitcoin, AssetType.bitcoinCash]
        assetTypesWithHDAddresses.forEach {
            let swipeAddresses = self.swipeAddresses(for: $0)
            let numberOfAddressesToDerive = Constants.Wallet.swipeToReceiveAddressCount - swipeAddresses.count
            if numberOfAddressesToDerive > 0 {
                wallet.getSwipeAddresses(Int32(numberOfAddressesToDerive), assetType: $0.legacy)
            }
        }
    }

    /// Gets address for the provided asset type
    /// - Parameter type: the type of the address
    /// - Parameter asset: the asset type
    /// - Returns: a candidate asset addresses
    func addresses(by type: AssetAddressType, asset: AssetType) -> [AssetAddress] {
        switch type {
        case .swipeToReceive:
            return swipeAddresses(for: asset)
        case .standard:
            fatalError("TODO")
        }
    }
    
    /// Gets the swipe addresses for the provided asset type
    /// - Parameter asset: the asset type
    /// - Returns: the asset address
    func swipeAddresses(for asset: AssetType) -> [AssetAddress] {
        let appSettings = BlockchainSettings.App.shared
        
        // TODO: In `BlockchainSettings.App`, create a method that receives an enum and returns a swipe address
        switch asset {
        case .ethereum:
            guard let swipeAddressForEther = appSettings.swipeAddressForEther else {
                return []
            }
            return [EthereumAddress(string: swipeAddressForEther)]
        case .stellar:
            guard let swipeAddressForStellar = appSettings.swipeAddressForStellar else {
                return []
            }
            return [StellarAddress(string: swipeAddressForStellar)]
        case .pax:
            guard let swipeAddressForPax = appSettings.swipeAddressForPax else {
                return []
            }
            return [PaxAddress(string: swipeAddressForPax)]
        case .bitcoinCash, .bitcoin:
            let swipeAddresses = KeychainItemWrapper.getSwipeAddresses(for: asset.legacy) as? [String] ?? []
            return AssetAddressFactory.create(fromAddressStringArray: swipeAddresses, assetType: asset)
        }
    }

    /// Removes the first swipe address for assetType.
    ///
    /// - Parameter assetType: the AssetType
    func removeFirstSwipeAddress(for assetType: AssetType) {
        KeychainItemWrapper.removeFirstSwipeAddress(for: assetType.legacy)
    }
    
    /// Removes a specific address for assetType.
    ///
    /// - Parameter address: the address
    /// - Parameter assetType: the AssetType
    /// - Parameter addressType: the type of the address
    func remove(address: String, for assetType: AssetType, addressType: AssetAddressType) {
        switch addressType {
        case .swipeToReceive:
            KeychainItemWrapper.removeSwipeAddress(address, assetType: assetType.legacy)
        case .standard:
            fatalError("\(#function) has not been implemented to support \(addressType)")
        }
    }

    /// Removes all swipe addresses for all assets
    @objc func removeAllSwipeAddresses() {
        KeychainItemWrapper.removeAllSwipeAddresses()
    }

    /// removes all swipe addresses for the provided AssetType
    ///
    /// - Parameter assetType: the AssetType
    @objc func removeAllSwipeAddresses(for assetType: AssetType) {
        KeychainItemWrapper.removeAllSwipeAddresses(for: assetType.legacy)
    }
}

extension AssetAddressRepository: WalletSwipeAddressDelegate {
    func onRetrievedSwipeToReceive(addresses: [String], assetType: AssetType) {
        addresses.forEach {
            KeychainItemWrapper.addSwipeAddress($0, assetType: assetType.legacy)
        }
    }
}

extension AssetAddressRepository {
    
    /// Checks whether an address has been used (has ever had a transaction)
    ///
    /// - Parameters:
    ///   - address: address to be checked with network request
    /// (usually the same as address unless checking for corresponding BTC address for BCH
    ///   - asset: asset type for the address. Currently only supports BTC and BCH.
    /// - Returns: A single with the address usage status
    func checkUsability(of address: String, asset: AssetType) -> Single<AddressUsageStatus> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            // Continue only if address reusability is not supported for the given asset type
            guard !asset.shouldAddressesBeReused else {
                Logger.shared.info("\(asset.description) addresses not supported for checking if it is unused.")
                single(.success(.unused(address: address)))
                return Disposables.create()
            }
            
            var assetAddress = AssetAddressFactory.create(fromAddressString: address, assetType: asset)
            if let bchAddress = assetAddress as? BitcoinCashAddress,
                let transformedBtcAddress = bchAddress.toBitcoinAddress(wallet: self.walletManager.wallet) {
                assetAddress = transformedBtcAddress
            }
            
            guard let urlString = BlockchainAPI.shared.assetInfoURL(for: assetAddress), let url = URL(string: urlString) else {
                Logger.shared.warning("Cannot construct URL to check if the address '\(address)' is unused.")
                single(.success(.unknown(address: address)))
                return Disposables.create()
            }
            
            // TODO: Inject
            NetworkManager.shared.session.sessionDescription = url.host
            let task = NetworkManager.shared.session.dataTask(with: url, completionHandler: { data, _, error in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                // TODO: Type program the parsing into `NetworkManager`
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject],
                    let transactions = json["txs"] as? [NSDictionary] else {
                        single(.error(NetworkError.jsonParseError))
                        return
                }
                let usage: AddressUsageStatus = transactions.isEmpty ? .unused(address: address) : .used(address: address)
                single(.success(usage))
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
