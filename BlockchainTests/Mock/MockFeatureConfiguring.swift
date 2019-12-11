//
//  FeatureConfiguring.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

class MockFeatureConfigurator: FeatureConfiguring {
    
    private let isEnabled: Bool
    
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    func configuration(for feature: AppFeature) -> AppFeatureConfiguration {
        return AppFeatureConfiguration(isEnabled: isEnabled)
    }
}
