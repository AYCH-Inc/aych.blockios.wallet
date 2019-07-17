//
//  CrashlyticsRecorder.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Firebase

/// Crashlytics implementation of `Recording`. Should be injected as a service.
final class CrashlyticsRecorder: Recording {

    // MARK: - Properties
    
    private unowned let application: UIApplication
    private let crashlytics: Crashlytics
    
    // MARK: - Setup
    
    init(crashlytics: Crashlytics = .sharedInstance(),
         application: UIApplication = .shared) {
        self.crashlytics = crashlytics
        self.application = application
    }
    
    // MARK: - ErrorRecording
    
    /// Records error using Crashlytics.
    /// If the only necessary recording data is the context, just call `error()` with no `error` parameter.
    /// - Parameter error: The error to be recorded by the crash service. defaults to `BreadcrumbError` instance.
    func error(_ error: Error) {
        crashlytics.recordError(error)
    }
    
    /// Breadcrumbs an error
    func error() {
        error(RecordingError.breadcrumb)
    }

    // MARK: - MessageRecording
    
    /// Records any type of message.
    /// If the only necessary recording data is the context, just call `record()` with no `message` parameter.
    /// - Parameter message: The message to be recorded by the crash service. defaults to an empty string.
    func record(_ message: String) {
        CLSLogv("%@", getVaList([message]))
    }
    
    /// Breadcrumbs a message
    func record() {
        record("")
    }
    
    // MARK: - UIOperationRecording
    
    /// Should be called if there is a suspicion that a UI action is performed on a background thread.
    /// In such case, a non-fatal error will be recorded.
    func recordIllegalUIOperationIfNeeded() {
        guard application.applicationState == .background else {
            return
        }
        error(RecordingError.changingUIOnBackgroundThread)
    }
}
