//
//  DataProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// A container for common crypto services.
/// Rule of thumb: If a service may be used by multiple clients,
/// and if there should be a single service per asset, it makes sense to place
/// that it inside a specialized container.
final class DataProvider: DataProviding {
        
    /// The default container
    static let `default` = DataProvider()
    
    /// Historical service that provides past prices for a given asset type
    let historicalPrices: HistoricalFiatPriceProviding
    
    /// Exchange service for any asset
    let exchange: ExchangeProviding
    
    /// Balance change service
    let balanceChange: BalanceChangeProviding
    
    /// Balance service for any asset
    let balance: BalanceProviding
    
    init(fiatCurrencyProvider: FiatCurrencyTypeProviding = BlockchainSettings.App.shared) {
        
        self.exchange = ExchangeProvider(
            ether: PairExchangeService(
                cryptoCurrency: .ethereum,
                fiatCurrencyProvider: fiatCurrencyProvider
        ),
            pax: PairExchangeService(
            cryptoCurrency: .pax,
            fiatCurrencyProvider: fiatCurrencyProvider
        ),
            stellar: PairExchangeService(
                cryptoCurrency: .stellar,
                fiatCurrencyProvider: fiatCurrencyProvider
        ),
            bitcoin: PairExchangeService(
                cryptoCurrency: .bitcoin,
                fiatCurrencyProvider: fiatCurrencyProvider
        ),
            bitcoinCash: PairExchangeService(
                cryptoCurrency: .bitcoinCash,
                fiatCurrencyProvider: fiatCurrencyProvider)
        )
        
        let etherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .ethereum,
            exchangeAPI: exchange[.ethereum],
            fiatCurrencyProvider: fiatCurrencyProvider
        )
        let bitcoinHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoin,
            exchangeAPI: exchange[.bitcoin],
            fiatCurrencyProvider: fiatCurrencyProvider
        )
        let bitcoinCashHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoinCash,
            exchangeAPI: exchange[.bitcoinCash],
            fiatCurrencyProvider: fiatCurrencyProvider
        )
        let stellarHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .stellar,
            exchangeAPI: exchange[.stellar],
            fiatCurrencyProvider: fiatCurrencyProvider
        )
        let paxHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .pax,
            exchangeAPI: exchange[.pax],
            fiatCurrencyProvider: fiatCurrencyProvider
        )
        
        self.historicalPrices = HistoricalFiatPriceProvider(
            ether: etherHistoricalFiatService,
            pax: paxHistoricalFiatService,
            stellar: stellarHistoricalFiatService,
            bitcoin: bitcoinHistoricalFiatService,
            bitcoinCash: bitcoinCashHistoricalFiatService
        )
        
        let etherBalanceFetcher = AssetBalanceFetcher(
            balance: WalletManager.shared.wallet.ethereum,
            exchange: exchange[.ethereum]
        )
        let paxBalanceFetcher = AssetBalanceFetcher(
            balance: ERC20AssetBalanceFetcher(),
            exchange: exchange[.pax]
        )
        let stellarBalanceFetcher = AssetBalanceFetcher(
            balance: StellarServiceProvider.shared.services.accounts,
            exchange: exchange[.stellar]
        )
        let bitcoinBalanceFetcher = AssetBalanceFetcher(
            balance: BitcoinAssetBalanceFetcher(),
            exchange: exchange[.bitcoin]
        )
        let bitcoinCashBalanceFetcher = AssetBalanceFetcher(
            balance: BitcoinCashAssetBalanceFetcher(),
            exchange: exchange[.bitcoinCash]
        )
        
        balance = BalanceProvider(
            ether: etherBalanceFetcher,
            pax: paxBalanceFetcher,
            stellar: stellarBalanceFetcher,
            bitcoin: bitcoinBalanceFetcher,
            bitcoinCash: bitcoinCashBalanceFetcher
        )
        
        balanceChange = BalanceChangeProvider(
            ether: AssetBalanceChangeProvider(
                balance: etherBalanceFetcher,
                prices: historicalPrices[.ethereum]
            ),
            pax: AssetBalanceChangeProvider(
                balance: paxBalanceFetcher,
                prices: historicalPrices[.pax]
            ),
            stellar: AssetBalanceChangeProvider(
                balance: stellarBalanceFetcher,
                prices: historicalPrices[.stellar]
            ),
            bitcoin: AssetBalanceChangeProvider(
                balance: bitcoinBalanceFetcher,
                prices: historicalPrices[.bitcoin]
            ),
            bitcoinCash: AssetBalanceChangeProvider(
                balance: bitcoinCashBalanceFetcher,
                prices: historicalPrices[.bitcoinCash]
            )
        )
    }
}
