//
//  PushNotificationClient.swift
//  Blockchain
//
//  Created by Jack on 22/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public class PushNotificationClient {
    
    public struct WalletCredentials {
        public let guid: String
        public let sharedKey: String
        
        public init?(guid: String?, sharedKey: String?) {
            guard let guid = guid, let sharedKey = sharedKey else {
                return nil
            }
            self.guid = guid
            self.sharedKey = sharedKey
        }
    }
    
    private let communicator: NetworkCommunicatorAPI
    
    init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.communicator = communicator
    }
    
    public func registerDeviceForPushNotifications(withDeviceToken token: String, credentials: WalletCredentials?) {
        // TODO: test deregistering from the server
        guard let credentials = credentials else {
            return
        }
        let pushNotificationsUrl = BlockchainAPI.shared.pushNotificationsUrl
        let guid = credentials.guid
        let sharedKey = credentials.sharedKey
        guard let url = URL(string: pushNotificationsUrl),
            let payload = PushNotificationAuthPayload(guid: guid, sharedKey: sharedKey, deviceToken: token),
            let body = BlockchainAPI.registerDeviceForPushNotifications(using: payload) else {
                return
        }
        var notificationRequest = URLRequest(url: url)
        notificationRequest.httpMethod = "POST"
        notificationRequest.httpBody = body
        notificationRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        notificationRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        // TODO:
        // * Use NetworkCommunicator to send request
        let task = Network.Dependencies.default.session.dataTask(with: notificationRequest, completionHandler: { data, response, error in
            guard error == nil else {
                Logger.shared.error("Error registering device with backend: \(error!.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject],
                let success = json["success"] as? Bool, success == true else {
                    return
            }
        })
        task.resume()
    }
}
