//
//  SessionGuidService.swift
//  Blockchain
//
//  Created by Daniel Huri on 12/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol SessionGuidServiceAPI: class {
    func sessionGuid(using token: String) -> Single<String>
}

final class SessionGuidService: SessionGuidServiceAPI {
        
    struct Payload: Encodable {
        let format = "json"
    }
    
    struct Response: Decodable {
        let guid: String
    }
    
    // MARK: - Properties
    
    /// Returns the session GUID
      
    func sessionGuid(using token: String) -> Single<String> {
        let request = NetworkRequest(
            endpoint: url,
            method: .get,
            headers: ["cookie": "SID=" + token],
            contentType: .json
        )
        return self.communicator
            .perform(request: request, responseType: Response.self)
            .map { $0.guid }
    }
    
    private let url = URL(string: BlockchainAPI.shared.sessionGuid + "?format=json")!
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.communicator = communicator
        
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: URL(string: BlockchainAPI.shared.sessionGuid + "?format=json")!) ?? []
        print(cookies)
    }
}

/// TODO: 
//function pollForSessionGUID(sessionToken) {
//  var promise = new Promise(function (resolve, reject) {
//    if (WalletStore.isPolling()) return;
//    WalletStore.setIsPolling(true);
//    var data = { format: 'json' };
//    var headers = { sessionToken: sessionToken };
//    var success = function success(obj) {
//      if (obj.guid) {
//        WalletStore.setIsPolling(false);
//        WalletStore.sendEvent('msg', { type: 'success', message: 'Authorization Successful' });
//        resolve();
//      } else {
//        if (WalletStore.getCounter() < 600) {
//          WalletStore.incrementCounter();
//          setTimeout(function () {
//            API.request('GET', 'wallet/poll-for-session-guid', data, headers).then(success).catch(error);
//          }, 2000);
//        } else {
//          WalletStore.setIsPolling(false);
//        }
//      }
//    };
//    var error = function error() {
//      WalletStore.setIsPolling(false);
//    };
//    API.request('GET', 'wallet/poll-for-session-guid', data, headers).then(success).catch(error);
//  });
//  return promise;
//}
