//
//  MockFeatureFetcher.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 26/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class MockFeatureFetcher: FeatureFetching {
    
    var expectedVariant = FeatureTestingVariant.variantA
    
    func fetch<Feature: Decodable>(for key: AppFeature) -> Single<Feature> {
        fatalError("\(#function) has not been implemented yet" )
    }
    
    func fetchInteger(for key: AppFeature) -> Single<Int> {
        fatalError("\(#function) has not been implemented yet" )
    }
    
    func fetchString(for key: AppFeature) -> Single<String> {
        fatalError("\(#function) has not been implemented yet" )
    }
    
    func fetchTestingVariant(for key: AppFeature) -> Single<FeatureTestingVariant> {
        return Single.just(expectedVariant)
    }
}
