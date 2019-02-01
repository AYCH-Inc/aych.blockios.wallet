//
//  PermissionsRequestor.swift
//  Blockchain
//
//  Created by Alex McGregor on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UserNotifications

/// `PermissionsRequestor` is for requesting access to the user's camera
/// as well as requesting access to push notifications. At the moment
/// we are only requesting for camera permissions in KYC.
class PermissionsRequestor {
    
    // MARK: Public Functions
    
    func requestPermissions(
        camera: Bool,
        notification: Bool = false,
        callback: @escaping () -> Void
        ) {
        
        let shouldDisplayCameraRequest = PermissionsRequestor.shouldDisplayCameraPermissionsRequest()
        let shouldDisplayNotificationsRequest = PermissionsRequestor.shouldDisplayNotificationsPermissionsRequest()
        
        // If we've asked the user for camera and/or notification permissions
        // we want to call the completion handler.
        switch (camera, notification) {
        case (true, true):
            let both = shouldDisplayCameraRequest && shouldDisplayNotificationsRequest
            guard both == true else { callback(); return }
        case (true, false):
            guard shouldDisplayCameraRequest == true else { callback(); return }
        case (false, true):
            guard shouldDisplayNotificationsRequest == true else { callback(); return }
        default:
            callback()
            return
        }
        
        if camera {
            queue.addOperation(cameraOperation)
            BlockchainSettings.App.shared.didRequestCameraPermissions = true
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
        let camera = AsyncBlockOperation { done in
            DispatchQueue.main.async(execute: {
                AVCaptureDevice.requestAccess(for: .video) { _ in
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
}
