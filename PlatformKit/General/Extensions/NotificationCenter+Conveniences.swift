//
//  NotificationCenter+Conveniences.swift
//  PlatformKit
//
//  Created by AlexM on 3/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension NotificationCenter {
    @discardableResult public static func when(_ name: NSNotification.Name, action: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: .main,
            using: action
        )
    }
}
