//
//  Config.swift
//  Blockchain
//
//  Created by Maurice A. on 3/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

@objc
extension Bundle {
    class func urlForAPI() -> String? {
        guard let host = Bundle.main.infoDictionary!["API_URL"] as? String else {
            return nil
        }
        return "https://\(host)"
    }
    class func urlForWallet() -> String? {
        guard let host = Bundle.main.infoDictionary!["WALLET_SERVER"] as? String else {
            return nil
        }
        return "https://\(host)"
    }
    class func uriForWebSocket() -> String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    class func uriForEthereumWebSocket() -> String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER_ETH"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    class func urlForBuyWebView() -> String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["BUY_WEBVIEW_URL"] as? String else {
            return nil
        }
        return "https://\(hostAndPath)"
    }
}
