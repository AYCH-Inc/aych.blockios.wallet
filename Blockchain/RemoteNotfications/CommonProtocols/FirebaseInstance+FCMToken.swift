//
//  FirebaseInstance+FCMToken.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Firebase

typealias RemoteNotificationTokenFetchResult = Result<RemoteNotification.Token, RemoteNotification.TokenFetchError>

protocol RemoteNotificationTokenFetching: class {
    func instanceID(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void)
}

extension InstanceID: RemoteNotificationTokenFetching {
    func instanceID(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void) {
        instanceID { (result, error) in
            if let error = error {
                handler(.failure(.external(error)))
            } else if let result = result {
                if result.token.isEmpty {
                    handler(.failure(.tokenIsEmpty))
                } else {
                    handler(.success(result.token))
                }
            } else {
                handler(.failure(.resultIsNil))
            }
        }
    }
}
