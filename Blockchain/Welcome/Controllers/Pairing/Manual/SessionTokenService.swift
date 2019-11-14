//
//  SessionTokenService.swift
//  Blockchain
//
//  Created by Daniel Huri on 12/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol SessionTokenServiceAPI: class {
    func requestSessionToken() -> Single<Void>
}

final class SessionTokenService: SessionTokenServiceAPI {
    
    struct Response: Decodable {
        let token: String
    }
    
    private let url = URL(string: BlockchainAPI.shared.walletSession)!
    private let communicator: NetworkCommunicatorAPI
    private let wallet: Wallet
    
    init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.communicator = communicator
        self.wallet = wallet
    }
    
    /// Requests a session token for the wallet, if not available already
    func requestSessionToken() -> Single<Void> {
        guard wallet.sessionToken == nil else { return .just(()) }
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            contentType: .json
        )
        return self.communicator
            .perform(request: request, responseType: Response.self)
            .map { $0.token }
            .do(onSuccess: { [weak self] token in
                self?.wallet.sessionToken = token
            })
            .mapToVoid()
    }
}

//function obtainSessionToken() {
//  var processResult = function processResult(data) {
//    if (!data.token || !data.token.length) {
//      return Promise.reject('Invalid session token');
//    }
//    return data.token;
//  };
//
//  return API.request('POST', 'wallet/sessions').then(processResult);
//}
//
//function establishSession(token) {
//  if (token) {
//    return Promise.resolve(token);
//  } else {
//    return this.obtainSessionToken();
//  }
//}

