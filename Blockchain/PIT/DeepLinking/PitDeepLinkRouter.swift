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
    private let coordinator: PitCoordinator
    init(appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
         coordinator: PitCoordinator = .shared) {
        self.appSettings = appSettings
        self.coordinator = coordinator
    }
    
    func routeIfNeeded() -> Bool {
        guard appSettings.didTapOnPitDeepLink else {
            return false
        }
        PitCoordinator.shared.start()
        return true
    }
}
