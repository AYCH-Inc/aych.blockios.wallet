//
//  AppSettingsAuthenticating.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Any feature remote configuration protocol
@objc
protocol FeatureConfiguring: class {
    @objc func configuration(for feature: AppFeature) -> AppFeatureConfiguration
}

protocol FeatureFetching: class {
    func fetch<Feature: Decodable>(for key: AppFeature) -> Single<Feature>
    func fetchInteger(for key: AppFeature) -> Single<Int>
    func fetchString(for key: AppFeature) -> Single<String>

}

/// This protocol is responsible for variant fetching
protocol FeatureVariantFetching: class {
    
    /// Returns an expected variant for the provided feature key
    /// - Parameter feature: the feature key
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    func fetchTestingVariant(for key: AppFeature) -> Single<FeatureTestingVariant>
    
    /// Returns an expected variant for the provided feature key.
    /// - Parameter feature: the feature key
    /// - Parameter defaultVariant: expected value to be returned if an error occurs
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    func fetchTestingVariant(for key: AppFeature, onErrorReturn defaultVariant: FeatureTestingVariant) -> Single<FeatureTestingVariant>
}
