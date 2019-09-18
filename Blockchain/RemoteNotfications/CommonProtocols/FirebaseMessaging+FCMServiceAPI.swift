//
//  FirebaseMessaging+FCMServiceAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import FirebaseMessaging

protocol FCMServiceAPI: class {
    var apnsToken: Data? { get set }
    @discardableResult
    func appDidReceiveMessage(_ message: [AnyHashable: Any]) -> MessagingMessageInfo
    func subscribe(toTopic topic: String, completion: FIRMessagingTopicOperationCompletion?)
}

extension Messaging: FCMServiceAPI {}
