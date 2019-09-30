//
//  SendPitAddressStatePresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

@objc
final class SendPitAddressStatePresenter: NSObject {

    // MARK: - Types
    
    /// When fetching a PIT address, we eitehr get a destination address or an error is thrown.
    /// In the event of an error, we're assuming this is because 2FA isn't enabled.
    enum PitAddressResult {
        case destination(String)
        case twoFactorRequired
        
        var address: String? {
            switch self {
            case .destination(let output):
                return output
            case .twoFactorRequired:
                return nil
            }
        }
        
        var is2FARequired: Bool {
            switch self {
            case .twoFactorRequired:
                return true
            case .destination:
                return false
            }
        }
    }
    
    // MARK: - Properties
    
    var viewModel: Single<PITAddressViewModel> {
        let model = PITAddressViewModel(assetType: assetType)
        return Single
            .zip(destinationAddress, isPITLinked)
            .map { addressResult, isLinked in
                model.isTwoFactorEnabled = !addressResult.is2FARequired
                model.address = addressResult.address
                model.isPITLinked = isLinked
                return model
        }
    }
    
    private var isPITLinked: Single<Bool> {
        return blockchainRepository.fetchNabuUser().map {
            return $0.hasLinkedPITAccount
        }
    }
    
    private var destinationAddress: Single<PitAddressResult> {
        return pitAddressFetcher.fetchAddress(for: assetType)
            .map { return .destination($0) }
            .catchError { error -> Single<PitAddressResult> in
                switch error {
                case PitAddressFetcher.FetchingError.twoFactorRequired:
                    return .just(.twoFactorRequired)
                default:
                    throw error
                }
            }
    }
    
    private let pitAddressFetcher: PitAddressFetching
    private let disposeBag = DisposeBag()
    private let assetType: AssetType
    private let blockchainRepository: BlockchainDataRepository
    
    init(assetType: AssetType,
         pitAddressFetcher: PitAddressFetching = PitAddressFetcher(),
         blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared) {
        self.assetType = assetType
        self.pitAddressFetcher = pitAddressFetcher
        self.blockchainRepository = blockchainRepository
    }
    
    // MARK: - Legacy (to be used only inside the ObjC code base)
    
    @objc
    init(assetType: LegacyAssetType) {
        self.assetType = AssetType(from: assetType)
        self.pitAddressFetcher = PitAddressFetcher()
        self.blockchainRepository = BlockchainDataRepository.shared
    }
    
    @objc
    func fetchAddressViewModel(completion: @escaping (PITAddressViewModel) -> Void) {
        return viewModel.observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { model in
                completion(model)
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: disposeBag)
    }
}
