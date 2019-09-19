//
//  WalletIntroductionInteractor.swift
//  Blockchain
//
//  Created by AlexM on 8/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol WalletIntroductionInteracting {
    
    // A `screen` is required as the introduction involves multiple screens. If the screen provided
    // does not have any further events, you will get an error, `WalletIntroductionError.invalidScreenForStep`.
    var screen: WalletIntroductionLocation.Screen { get }
    
    /// The last location that the user left off at during the introduction flow
    var lastLocation: Maybe<WalletIntroductionLocation> { get }
    
    // The location that the user should resume at. This defaults to the start of the introduction
    // should the `lastLocation` be `.empty()`
    var startingLocation: Single<WalletIntroductionLocation> { get }
    
    // Returns a `Bool` indicating whether the introduction has been completed.
    var isIntroductionComplete: Single<Bool> { get }
    
    // Returns the next `WalletIntroductionLocation` in the introduction flow. This will
    // throw an error should there not be a location the follows the `location` provided.
    func next(_ location: WalletIntroductionLocation) -> Single<WalletIntroductionLocation>
}

class WalletIntroductionInteractor: WalletIntroductionInteracting {
    
    let screen: WalletIntroductionLocation.Screen
    private let onboardingSettings: BlockchainSettings.Onboarding
    private let stepperAPI: WalletIntroductionLocationSequenceAPI = WalletIntroductionLocationSequencer()
    
    init(onboardingSettings: BlockchainSettings.Onboarding = .shared, screen: WalletIntroductionLocation.Screen) {
        self.onboardingSettings = onboardingSettings
        self.screen = screen
    }
    
    var isIntroductionComplete: Single<Bool> {
        return lastLocation.ifEmpty(default: .starter).flatMap(weak: self, { (self, step) -> Single<Bool> in
            return self.next(step).map { _ -> Bool in
                return false
            }.catchErrorJustReturn(true)
        })
    }
    
    var startingLocation: Single<WalletIntroductionLocation> {
        guard let step = onboardingSettings.walletIntroLatestLocation else { return defaultStartLocation }
        return next(step).flatMap(weak: self, { (self, location) -> Single<WalletIntroductionLocation> in
            guard location.screen == self.screen else { return Single.error(WalletIntroductionError.invalidScreenForStep) }
            return Single.just(location)
        })
    }
    
    var lastLocation: Maybe<WalletIntroductionLocation> {
        guard let step = onboardingSettings.walletIntroLatestLocation else { return Maybe.empty() }
        return Maybe.just(step)
    }
    
    func next(_ location: WalletIntroductionLocation) -> Single<WalletIntroductionLocation> {
        return stepperAPI.nextLocation(from: location)
    }
    
    private var defaultStartLocation: Single<WalletIntroductionLocation> {
        if WalletIntroductionLocation.starter.screen == screen {
            return Single.just(.starter)
        } else {
            return Single.error(WalletIntroductionError.invalidScreenForStep)
        }
    }
}
