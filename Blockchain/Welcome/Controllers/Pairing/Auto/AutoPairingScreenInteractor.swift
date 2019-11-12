//
//  AutoPairingScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

final class AutoPairingScreenInteractor {
    
    // MARK: - Properties
    
    /// Streams potential parsing errors
    var error: Observable<Error> {
        return errorRelay.asObservable()
    }
    
    let parser = PairingCodeQRCodeParser()
    private let authenticationCoordinator: AuthenticationCoordinator
    private let authenticationManager: AuthenticationManager
    private let analyticsRecorder: AnalyticsEventRecording
    private let errorRelay = PublishRelay<Error>()

    // MARK: - Setup
    
    init(authenticationCoordinator: AuthenticationCoordinator = .shared,
         authenticationManager: AuthenticationManager = .shared,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
        self.authenticationCoordinator = authenticationCoordinator
        self.authenticationManager = authenticationManager
    }
    
    func handlePairingCodeResult(result: Result<PairingCodeQRCodeParser.PairingCode,
                                                PairingCodeQRCodeParser.PairingCodeParsingError>) {
        switch result {
        case .success(let pairingCode):
            analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletAutoPairing)
            authenticationManager.authenticate(
                using: pairingCode.passcodePayload,
                andReply: authenticationCoordinator.authHandler
            )
        case .failure(let error):
            analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletAutoPairingError)
            errorRelay.accept(error)
        }
    }
}
