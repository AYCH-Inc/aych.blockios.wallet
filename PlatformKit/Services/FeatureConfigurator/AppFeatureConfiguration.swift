//
//  AppFeatureConfiguration.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Defines a configuration for a given `AppFeature`
@objc
public class AppFeatureConfiguration: NSObject {

    /// To be thrown if necessary when the feature is not remotely disabled
    public enum ConfigError: Error {
        
        /// Feature is remotely disabled
        case disabled
    }
    
    @objc
    public let isEnabled: Bool

    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}
