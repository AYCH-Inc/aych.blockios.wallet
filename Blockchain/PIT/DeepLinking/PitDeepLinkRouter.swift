//
//  PitDeepLinkRouter.swift
//  Blockchain
//
//  Created by AlexM on 7/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class PitDeepLinkRouter: DeepLinkRouting {
    
    private let appSettings: BlockchainSettings.App
    
    init(appSettings: BlockchainSettings.App = BlockchainSettings.App.shared) {
        self.appSettings = appSettings
    }
    
    func routeIfNeeded() {
        if appSettings.didTapOnPitDeepLink {
            PitCoordinator.shared.start()
        }
    }
}
