//
//  AutoPairingScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit
import PlatformKit

final class AutoPairingScreenInteractor {
    
    // MARK: - Properties
    
    /// Streams potential parsing errors
    var error: Observable<Error> {
        return errorRelay.asObservable()
    }
    
    let parser = PairingCodeQRCodeParser()
    private let authenticationCoordinator: AuthenticationCoordinator
    private let analyticsRecorder: AnalyticsEventRecording
    private let errorRelay = PublishRelay<Error>()

    // MARK: - Setup
    
    init(authenticationCoordinator: AuthenticationCoordinator = .shared,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
        self.authenticationCoordinator = authenticationCoordinator
    }
    
    func handlePairingCodeResult(result: Result<PairingCodeQRCodeParser.PairingCode,
                                                PairingCodeQRCodeParser.PairingCodeParsingError>) {
        switch result {
        case .success(let pairingCode):
            analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletAutoPairing)
            authenticationCoordinator.authenticate(using: pairingCode.passcodePayload)
        case .failure(let error):
            analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletAutoPairingError)
            errorRelay.accept(error)
        }
    }
}
