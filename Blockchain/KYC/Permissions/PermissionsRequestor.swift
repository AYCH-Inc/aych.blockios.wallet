//
//  PermissionsRequestor.swift
//  Blockchain
//
//  Created by Alex McGregor on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit
import UserNotifications

/// `PermissionsRequestor` is for requesting access to the user's camera
/// as well as requesting access to push notifications. At the moment
/// we are only requesting for camera permissions in KYC.
class PermissionsRequestor {
    
    enum Permission {
        case camera
        case notification
        case microphone
    }
    
    private let analyticsRecorder: AnalyticsEventRecording
    
    init(analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
    }
    
    // MARK: Public Functions
    
    func requestPermissions(_ permissions: [Permission], callback: @escaping () -> Void) {
        let shouldDisplayCameraRequest = PermissionsRequestor.shouldDisplayCameraPermissionsRequest()
        let shouldDisplayNotificationsRequest = PermissionsRequestor.shouldDisplayNotificationsPermissionsRequest()
        let shouldDisplayMicrophoneRequest = PermissionsRequestor.shouldDisplayMicrophonePermissionsRequest()
        
        let camera = permissions.contains { $0 == .camera }
        let microphone = permissions.contains { $0 == .microphone }
        let notification = permissions.contains { $0 == .notification }
        
        // If we've asked the user for camera and/or notification permissions
        // we want to call the completion handler.
        switch (camera, microphone, notification) {
        case (true, true, true):
            let all = shouldDisplayCameraRequest && shouldDisplayNotificationsRequest && shouldDisplayMicrophoneRequest
            guard all == true else { callback(); return }
        case (true, true, false):
            guard shouldDisplayCameraRequest == true else { callback(); return }
            guard shouldDisplayMicrophoneRequest == true else { callback(); return }
        case (false, true, true):
            guard shouldDisplayMicrophoneRequest == true else { callback(); return }
            guard shouldDisplayNotificationsRequest == true else { callback(); return }
        case (true, false, true):
            guard shouldDisplayCameraRequest == true else { callback(); return }
            guard shouldDisplayNotificationsRequest == true else { callback(); return }
        case (false, false, true):
            guard shouldDisplayNotificationsRequest == true else { callback(); return }
        case (true, false, false):
            guard shouldDisplayCameraRequest == true else { callback(); return }
        case (false, true, false):
            guard shouldDisplayMicrophoneRequest == true else { callback(); return }
        default:
            callback()
            return
        }
        
        if camera {
            queue.addOperation(cameraOperation)
            BlockchainSettings.App.shared.didRequestCameraPermissions = true
        }
        
        if microphone {
            queue.addOperation(microphoneOperation)
            BlockchainSettings.App.shared.didRequestMicrophonePermissions = true
        }
        
        if notification {
            queue.addOperation(pushOperation)
            BlockchainSettings.App.shared.didRequestNotificationPermissions = true
        }
        
        queue.addOperation {
            DispatchQueue.main.async(execute: {
                callback()
            })
        }
    }
    
    // MARK: Private Lazy Properties (Operations)
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var cameraOperation: AsyncBlockOperation = {
        let camera = AsyncBlockOperation { [weak self] done in
            DispatchQueue.main.async(execute: {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysCameraApprove
                        )
                    } else {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysCameraDecline
                        )
                    }
                    done()
                }
            })
        }
        return camera
    }()
    
    private lazy var pushOperation: AsyncBlockOperation = {
        let push = AsyncBlockOperation { done in
            DispatchQueue.main.async(execute: {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound],
                    completionHandler: { (granted, error) in
                    done()
                })
            })
        }
        return push
    }()
    
    private lazy var microphoneOperation: AsyncBlockOperation = {
        let microphone = AsyncBlockOperation { [weak self] done in
            DispatchQueue.main.async(execute: {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    if granted {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysMicApprove
                        )
                    } else {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysMicDecline
                        )
                    }
                    done()
                }
            })
        }
        return microphone
    }()
    
    // MARK: Private Static Functions
    
    private static func validatePermissionsAvailability(completion: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let enabled = cameraPermissionsUndetermined() && settings.authorizationStatus == .authorized
            completion(enabled)
        }
    }
    
    // MARK: Public Static Functions
    
    static func shouldDisplayCameraPermissionsRequest() -> Bool {
        return !BlockchainSettings.App.shared.didRequestCameraPermissions
    }
    
    static func shouldDisplayNotificationsPermissionsRequest() -> Bool {
        return !BlockchainSettings.App.shared.didRequestNotificationPermissions
    }
    
    static func shouldDisplayMicrophonePermissionsRequest() -> Bool {
        return !BlockchainSettings.App.shared.didRequestMicrophonePermissions
    }
    
    /// This is when the system hasn't asked the user for camera permissions
    static func cameraPermissionsUndetermined() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }
    
    static func cameraEnabled() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    static func cameraRefused() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return  status == .denied || status == .restricted
    }
    
    static func microphonePermissionsUndetermined() -> Bool {
        return AVAudioSession.sharedInstance().microphonePermissionsUndetermined()
    }
    
    static func microphoneEnabled() -> Bool {
        return AVAudioSession.sharedInstance().microphoneEnabled()
    }
    
    static func microphoneRefused() -> Bool {
        return AVAudioSession.sharedInstance().microphoneRefused()
    }
}

extension AVAudioSession {
    func microphoneEnabled() -> Bool {
        return recordPermission == .granted
    }
    
    func microphonePermissionsUndetermined() -> Bool {
        return recordPermission == .undetermined
    }
    
    func microphoneRefused() -> Bool {
        return recordPermission == .denied
    }
}
