//
//  AddressFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

/// This is temporary as the `SendBitcoinViewController` will likely be deprecated soon.
@objc class PITAddressViewModel: NSObject {
    @objc let assetType: LegacyAssetType
    @objc var isPITLinked: Bool = false
    @objc var pitDestinationAddress: String?
    
    init(assetType: LegacyAssetType) {
        self.assetType = assetType
    }
}

/// When fetching a PIT address, we eitehr get a destination address or an error is thrown.
/// In the event of an error, we're assuming this is because 2FA isn't enabled.
enum PitAddressResult {
    case destination(String)
    case configurationDisabled
    case twoFactorRequired
    case unknown
}

extension PitAddressResult {
    var address: String? {
        switch self {
        case .destination(let output):
            return output
        case .twoFactorRequired,
             .unknown,
             .configurationDisabled:
            return nil
        }
    }
}

// TODO: Remove this layer once the send screens are migrated to Swift
/// Bridging layer for Swift-ObjC, since ObjC isn't compatible with RxSwift
@objc
class BridgeAddressFetcher: NSObject {
    
    // MARK: - Properties
    
    private let pitAddressFetcher: PitAddressFetching = PitAddressFetcher()
    private let blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared
    private let assetType: LegacyAssetType
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    @objc init(assetType: LegacyAssetType) {
        self.assetType = assetType
        super.init()
    }
    
    private var viewModel: Single<PITAddressViewModel> {
        let model = PITAddressViewModel(assetType: assetType)
        return Single
            .zip(destinationAddress, isPITLinked)
            .map { addressResult, isLinked in
                if case .configurationDisabled = addressResult {
                    model.isPITLinked = false
                } else {
                    model.isPITLinked = isLinked
                }
                model.pitDestinationAddress = addressResult.address
                model.isPITLinked = isLinked
                return model
        }
    }
    
    private var destinationAddress: Single<PitAddressResult> {
        return pitAddressFetcher.fetchAddress(for: AssetType(from: assetType)).map {
            return .destination($0)
        }
        .catchError { (error) -> Single<PitAddressResult> in
            if let configuration = error as? AppFeatureConfiguration.ConfigError, configuration == .disabled {
                return Single.just(.configurationDisabled)
            }
            if let networkError = error as? NetworkCommunicatorError {
                if case let .serverError(serverError) = networkError, let nabuError = serverError.nabuError {
                    let result: PitAddressResult = nabuError.code == .bad2fa ? .twoFactorRequired : .unknown
                    return Single.just(result)
                }
            }
            return Single.just(.unknown)
        }
    }
    
    private var isPITLinked: Single<Bool> {
        return blockchainRepository.fetchNabuUser().map {
            return $0.hasLinkedPITAccount
        }
    }
    
    @objc func fetchAddressViewModel(completion: @escaping (PITAddressViewModel) -> Void) {
        return viewModel.observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { model in
                completion(model)
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: disposeBag)
    }
}
