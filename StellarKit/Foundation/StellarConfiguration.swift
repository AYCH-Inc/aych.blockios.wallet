//
//  StellarConfiguration.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

private struct HorizonServer {
    fileprivate struct Blockchain {
        fileprivate static let production = "https://horizon.blockchain.info"
    }
    
    fileprivate struct Stellar {
        fileprivate static let production = "https://horizon.stellar.org"
        fileprivate static let test = "https://horizon-testnet.stellar.org"
    }
}

public struct StellarConfiguration {
    public let sdk: StellarSDK
    public let network: Network
    
    public init(sdk: StellarSDK, network: Network) {
        self.sdk = sdk
        self.network = network
    }
    
    public init(horizonURL: String) {
        self.init(
            sdk: StellarSDK(withHorizonUrl: horizonURL),
            network: Network.public
        )
    }
}

extension StellarConfiguration {
    public struct Blockchain {
        public static let production = StellarConfiguration(
            sdk: StellarSDK(withHorizonUrl: HorizonServer.Blockchain.production),
            network: Network.public
        )
    }
    
    public struct Stellar {
        public static let production = StellarConfiguration(
            sdk: StellarSDK(withHorizonUrl: HorizonServer.Stellar.production),
            network: Network.public
        )
        
        public static let test = StellarConfiguration(
            sdk: StellarSDK(withHorizonUrl: HorizonServer.Stellar.test),
            network: Network.testnet
        )
    }
}
