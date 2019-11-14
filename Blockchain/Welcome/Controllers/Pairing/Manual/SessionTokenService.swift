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
    func setupSessionToken() -> Completable
}

final class SessionTokenService: SessionTokenServiceAPI {
    
    // MARK: - Types
    
    enum FetchError: Error {
        case missingToken
    }
    
    private struct Response: Decodable {
        let token: String?
    }
    
    // MARK: - Properties
    
    private let url = URL(string: BlockchainAPI.shared.walletSession)!
    private let communicator: NetworkCommunicatorAPI
    private let repository: SessionTokenRepositoryAPI
    
    // MARK: - Setup
    
    init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared,
         repository: SessionTokenRepositoryAPI) {
        self.communicator = communicator
        self.repository = repository
    }
    
    /// Requests a session token for the wallet, if not available already
    func setupSessionToken() -> Completable {
        guard !repository.hasSessionToken else { return .empty() }
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            contentType: .json
        )
        return self.communicator
            .perform(request: request, responseType: Response.self)
            .map { $0.token }
            .map{ token -> String in
                guard let token = token else { throw FetchError.missingToken }
                return token
            }
            .do(onSuccess: { [weak self] token in
                self?.repository.sessionToken = token
            })
            .asCompletable()
    }
}
