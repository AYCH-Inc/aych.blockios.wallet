//
//  FirebaseInstance+FCMToken.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

typealias RemoteNotificationTokenFetchResult = Result<RemoteNotification.Token, RemoteNotification.TokenFetchError>

/// This is used to separate firebase from the rest of the remote notification logic
protocol RemoteNotificationTokenFetching: class {
    func instanceID(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void)
}
