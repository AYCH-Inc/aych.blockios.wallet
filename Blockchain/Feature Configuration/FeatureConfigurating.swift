//
//  AppSettingsAuthenticating.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Any feature remote configuration protocol
@objc
protocol FeatureConfiguring: class {
    @objc func configuration(for feature: AppFeature) -> AppFeatureConfiguration
}
