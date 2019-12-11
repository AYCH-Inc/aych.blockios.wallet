//
//  RemoteNotificationNetworkService.swift
//  Blockchain
//
//  Created by Jack on 22/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

/// Remote notification network service
final class RemoteNotificationNetworkService {
    
    // MARK: - Types
    
    enum PushNotificationError: Error {
        case registrationFailure
        case missingCredentials
        case emptyCredentials
        case couldNotBuildRequestBody
    }
    
    private struct RegistrationResponseData: Decodable {
        let success: Bool
    }

    // MARK: - Properties
    
    private let url = BlockchainAPI.shared.pushNotificationsUrl
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Setup
    
    init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.communicator = communicator
    }
}

// MARK: - RemoteNotificationNetworkServicing

extension RemoteNotificationNetworkService: RemoteNotificationNetworkServicing {
    func register(with token: String,
                  using credentialsProvider: WalletCredentialsProviding) -> Single<Void> {
        let body: Data
        do {
            guard let guid = credentialsProvider.legacyGuid, let sharedKey = credentialsProvider.legacySharedKey else {
                throw PushNotificationError.missingCredentials
            }
            guard !guid.isEmpty && !sharedKey.isEmpty else {
                throw PushNotificationError.emptyCredentials
            }
            
            let builder = try RemoteNotificationTokenQueryParametersBuilder(guid: guid, sharedKey: sharedKey, token: token)
            guard let parameters = builder.parameters else {
                throw PushNotificationError.couldNotBuildRequestBody
            }
            body = parameters
        } catch {
            return .error(error)
        }
        
        let url = URL(string: self.url)!

        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: body,
            contentType: .formUrlEncoded
        )
        return communicator.perform(request: request)
            .flatMap { (payload: RegistrationResponseData) -> Single<Void> in
                guard payload.success else { throw PushNotificationError.registrationFailure }
                return .just(())
            }
    }
}
