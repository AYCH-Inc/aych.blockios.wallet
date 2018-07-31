//
//  NotificationCenter+Conveniences.swift
//  Blockchain
//
//  Created by AlexM on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension NotificationCenter {
    @discardableResult static func when(_ name: NSNotification.Name, action: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: .main,
            using: action
        )
    }

    static func post(_ name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: name,
                object: object,
                userInfo: userInfo
            )
        }
    }
}
