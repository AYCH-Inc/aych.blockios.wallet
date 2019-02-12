//
//  PriceServiceClient.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol PriceServiceAPI {
    func fiatPrice(forAssetType assetType: AssetType, fiatSymbol: String) -> Single<PriceInFiatValue>
}

/// Class for interacting with Blockchain's Service-Price backend service. This
/// service is in charge of all price related data (e.g. crypto to fiat prices, etc.)
/// Spec: https://api.blockchain.com/price/specs
class PriceServiceClient: PriceServiceAPI {

    typealias AssetTypesToPrices = [AssetType: PriceInFiatValue]

    func fiatPrice(forAssetType assetType: AssetType, fiatSymbol: String) -> Single<PriceInFiatValue> {
        guard let baseUrl = URL(string: BlockchainAPI.shared.servicePriceUrl) else {
            return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        guard let url = URL.endpoint(
            baseUrl,
            pathComponents: ["index"],
            queryParameters: ["base": assetType.symbol, "quote": fiatSymbol]
        ) else {
            return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        return NetworkRequest.GET(url: url, type: PriceInFiat.self).map {
            $0.toPriceInFiatValue(currencyCode: fiatSymbol)
        }
    }

    /// Returns a Single that emits a mapping between an AssetType and it's price in fiat
    ///
    /// - Parameter fiatSymbol: the fiat to convert to
    /// - Returns: a Single emitting an AssetTypesToPrices
    func allPrices(fiatSymbol: String) -> Single<AssetTypesToPrices> {
        let fiatPrices: [Single<(AssetType, PriceInFiatValue)>] = AssetType.all.map { assetType in
            return fiatPrice(
                forAssetType: assetType,
                fiatSymbol: fiatSymbol
            ).catchError { error -> Single<PriceInFiatValue> in
                // If there's an error with the network call, just return "0" for the price
                Logger.shared.error("Failed to fetch fiat price for asset type \(assetType.symbol). Error: \(error)")
                return Single.just(
                    PriceInFiat.empty.toPriceInFiatValue(currencyCode: fiatSymbol)
                )
            }.map { priceInFiat -> (AssetType, PriceInFiatValue) in
                return (assetType, priceInFiat)
            }
        }
        return Single.zip(fiatPrices, { results -> AssetTypesToPrices in
            var assetTypesToPrices: [AssetType: PriceInFiatValue] = [:]
            results.forEach { assetType, priceInFiat in
                assetTypesToPrices[assetType] = priceInFiat
            }
            return assetTypesToPrices
        })
    }
}
