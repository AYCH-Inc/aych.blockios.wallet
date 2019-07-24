//
//  AppFeatureConfiguration.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Defines a configuration for a given `AppFeature`
@objc class AppFeatureConfiguration: NSObject {

    /// To be thrown if necessary when the feature is not remotely disabled
    enum ConfigError: Error {
        
        /// Feature is remotely disabled
        case disabled
    }
    
    @objc let isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}
