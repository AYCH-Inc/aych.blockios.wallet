//
//  UIApplication+RemoteNotificationsAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

protocol UIApplicationRemoteNotificationsAPI: class {
    func registerForRemoteNotifications()
}

extension UIApplication: UIApplicationRemoteNotificationsAPI {}
