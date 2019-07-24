//
//  AddressFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

// TODO: Remove this layer once the send screens are migrated to Swift
/// Bridging layer for Swift-ObjC, since ObjC isn't compatible with RxSwift
@objc
class BridgeAddressFetcher: NSObject {
    
    // MARK: - Properties
    
    private let pitAddressFetcher: PitAddressFetching
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(pitAddressFetcher: PitAddressFetching = PitAddressFetcher()) {
        self.pitAddressFetcher = pitAddressFetcher
        super.init()
    }
    
    // TODO: remove this - temporary solution because of ObjC compatibility
    override init() {
        self.pitAddressFetcher = PitAddressFetcher()
        super.init()
    }
    
    @objc func fetchAddress(for asset: LegacyAssetType,
                            completion: @escaping (String?) -> Void) {
        pitAddressFetcher.fetchAddress(for: AssetType(from: asset))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { address in
                completion(address)
            }, onError: { _ in
                completion(nil)
            })
            .disposed(by: disposeBag)
    }
}
