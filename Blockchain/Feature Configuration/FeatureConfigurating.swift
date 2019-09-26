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
