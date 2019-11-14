//
//  GetWalletService.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class GetWalletService {
    
    struct ErrorResponse: Decodable, Error {
        let authorization_required: Bool
    }
    
    struct Response: Decodable {

    }
    
    // MARK: - Properties
    
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup

    init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.communicator = communicator
    }

    func wallet(using guid: String = WalletManager.shared.wallet.guid!, token: String) -> Single<Result<Response, ErrorResponse>> {
        let time = Int(Date().timeIntervalSince1970 * 1000)
        let url = URL(string: BlockchainAPI.shared.wallet(with: guid) + "?format=json&ct=\(time)")!
        let request = NetworkRequest(
            endpoint: url,
            method: .get,
            headers: ["sessionToken": token],
            contentType: .json
        )
        return self.communicator
            .perform(request: request, responseType: Response.self, errorResponseType: ErrorResponse.self)
    }
}

//// sharedKey is optional
//// token must be present if sharedKey isn't
//function callGetWalletEndpoint(guid, sharedKey, sessionToken) {
//  var clientTime = new Date().getTime();
//  var data = { format: 'json', resend_code: null, ct: clientTime };
//  var headers = {};
//
//  if (sharedKey) {
//    data.sharedKey = sharedKey;
//  } else {
//    assert(sessionToken, 'Session token required');
//    headers.sessionToken = sessionToken;
//  }
//  return API.request('GET', 'wallet/' + guid, data, headers);
//}
