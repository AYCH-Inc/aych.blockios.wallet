//
//  Config.swift
//  Blockchain
//
//  Created by Maurice A. on 3/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
//  Note:
//  replacingOccurrences(of: "\\", with: "") is needed because URLs are escaped in the .xcconfig files.

@objc
extension Bundle {
    class func urlForAPI() -> String? {
        guard let url = Bundle.main.infoDictionary!["API_URL"] as? String else { return nil }
        return url.replacingOccurrences(of: "\\", with: "")
    }
    class func urlForWallet() -> String? {
        guard let url = Bundle.main.infoDictionary!["WALLET_SERVER"] as? String else { return nil }
        return url.replacingOccurrences(of: "\\", with: "")
    }
    class func uriForWebSocket() -> String? {
        guard let uri = Bundle.main.infoDictionary!["WEBSOCKET_SERVER"] as? String else { return nil }
        return uri.replacingOccurrences(of: "\\", with: "")
    }
    class func uriForEthereumWebSocket() -> String? {
        guard let uri = Bundle.main.infoDictionary!["WEBSOCKET_SERVER_ETH"] as? String else { return nil }
        return uri.replacingOccurrences(of: "\\", with: "")
    }
    class func urlForBuyWebView() -> String? {
        guard let url = Bundle.main.infoDictionary!["BUY_WEBVIEW_URL"] as? String else { return nil }
        return url.replacingOccurrences(of: "\\", with: "")
    }
}
