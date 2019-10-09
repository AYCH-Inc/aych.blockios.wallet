//
//  RemoteNotificationAuthorizer.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import UserNotifications
import PlatformKit

final class RemoteNotificationAuthorizer {
    
    // MARK: - Types
    
    /// Any potential error that may be risen during authrorization request
    enum ServiceError: Error {
    
        /// Any system error
        case system(Error)
        
        /// End-user has not granted
        case permissionDenied
        
        /// Thrown if the authorization status should be `.authorized` but it's not
        case unauthorizedStatus
        
        /// Authrization was already granted / refused
        case statusWasAlreadyDetermined
    }
    
    // MARK: - Private Properties
    
    private let application: UIApplicationRemoteNotificationsAPI
    private let analyticsRecorder: AnalyticsEventRecording
    private let userNotificationCenter: UNUserNotificationCenterAPI
    private let options: UNAuthorizationOptions
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(application: UIApplicationRemoteNotificationsAPI = UIApplication.shared,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         userNotificationCenter: UNUserNotificationCenterAPI = UNUserNotificationCenter.current(),
         options: UNAuthorizationOptions = [.alert, .badge, .sound]) {
        self.application = application
        self.analyticsRecorder = analyticsRecorder
        self.userNotificationCenter = userNotificationCenter
        self.options = options
    }

    // MARK: - Private Accessors
    
    private func requestAuthorization() -> Single<Void> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionSysNotifRequest)
                self.userNotificationCenter.requestAuthorization(options: self.options) { [weak self] isGranted, error in
                    guard let self = self else { return }
                    guard error == nil else {
                        observer(.error(ServiceError.system(error!)))
                        return
                    }
                    guard isGranted else {
                        self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionSysNotifDecline)
                        observer(.error(ServiceError.permissionDenied))
                        return
                    }
                    self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionSysNotifApprove)
                    observer(.success(()))
                }
                return Disposables.create()
        }
    }
    
    private var isNotDetermined: Single<Bool> {
        return status.map { $0 == .notDetermined }
    }
}

// MARK: - RemoteNotificationAuthorizationStatusProviding

extension RemoteNotificationAuthorizer: RemoteNotificationAuthorizationStatusProviding {
    /// A `Single` that streams the authorization status of the notifications, on demand.
    var status: Single<UNAuthorizationStatus> {
        return Single<UNAuthorizationStatus>
            .create(weak: self) { (self, observer) -> Disposable in
                self.userNotificationCenter.getAuthorizationStatus(completionHandler: { status in
                    observer(.success(status))
                })
                return Disposables.create()
            }
    }
}

// MARK: - RemoteNotificationRegistering

extension RemoteNotificationAuthorizer: RemoteNotificationRegistering {
    /// Registers for remote notifications ONLY if the authorization status is `.authorized`.
    /// Should be called at the application startup after first initializing Firebase Messaging.
    func registerForRemoteNotificationsIfAuthorized() -> Single<Void> {
        return isAuthorized
            .map { isAuthorized -> Void in
                guard isAuthorized else {
                    throw ServiceError.unauthorizedStatus
                }
                return ()
            }
            .observeOn(MainScheduler.instance)
            .do(
                onSuccess: { [unowned application] _ in
                    application.registerForRemoteNotifications()
                },
                onError: { error in
                    Logger.shared.error("Token registration failed with error: \(error.localizedDescription)")
                }
            )
    }
}

// MARK: - RemoteNotificationAuthorizing

extension RemoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting {
    // TODO: Handle a `.denied` case
    /// Request authorization for remote notifications if the status is not yet determined.
    func requestAuthorizationIfNeeded() -> Single<Void> {
        return isNotDetermined
            .map { isNotDetermined -> Void in
                guard isNotDetermined else {
                    throw ServiceError.statusWasAlreadyDetermined
                }
                return ()
            }
            .observeOn(MainScheduler.instance)
            .flatMap(weak: self, { (self, status) -> Single<Void> in
                return self.requestAuthorization()
            })
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { [unowned application] _ in
                application.registerForRemoteNotifications()
                }, onError: { error in
                    Logger.shared.error("Remote notification authorization failed with error: \(error)")
            })
    }
}
