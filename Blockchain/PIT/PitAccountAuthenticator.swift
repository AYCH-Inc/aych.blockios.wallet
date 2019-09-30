//
//  PitAccountAuthenticator.swift
//  Blockchain
//
//  Created by AlexM on 7/15/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

protocol PitAccountAuthenticatorAPI {
    typealias LinkID = String
    var pitLinkID: Single<LinkID> { get }
    var pitURL: Single<URL> { get }
    var nabuUser: Observable<NabuUser> { get }
    func linkToExistingPitUser(linkID: LinkID) -> Completable
}

class PitAccountAuthenticator: PitAccountAuthenticatorAPI {
    
    private let blockchainRepository: BlockchainDataRepository
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: PITClientAPI
    private let campaignComposer: CampaignComposer
    
    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         clientAPI: PITClientAPI = PITClient(communicatorAPI: NetworkCommunicator.shared),
         campaignComposer: CampaignComposer = CampaignComposer()) {
        self.blockchainRepository = blockchainRepository
        self.authenticationService = authenticationService
        self.client = clientAPI
        self.campaignComposer = campaignComposer
    }
    
    var pitLinkID: Single<LinkID> {
        return authenticationService.getSessionToken()
            .flatMap(weak: self, { (self, sessionToken) -> Single<LinkID> in
                return self.client.linkID(sessionToken.token)
            })
    }
    
    var pitURL: Single<URL> {
        return Single
            .zip(blockchainRepository.fetchNabuUser(),
                 pitLinkID,
                 campaignComposer.pitCampaign)
            .flatMap(weak: self, { (self, payload) -> Single<URL> in
                let user = payload.0
                let linkID = payload.1
                let campaignKeyValuePairs = payload.2
                
                let email = self.percentEscapeString(user.email.address)
                guard let apiURL = URL(string: BlockchainAPI.shared.pitURL) else {
                    return Single.error(PITLinkingAPIError.unknown)
                }
                
                let pathComponents = ["trade", "link", linkID]
                var queryParams = Dictionary(
                    uniqueKeysWithValues: campaignKeyValuePairs.map { ($0.rawValue, $1.rawValue) }
                )
                queryParams += ["email": email]
                
                guard let endpoint = URL.endpoint(apiURL, pathComponents: pathComponents, queryParameters: queryParams) else {
                    return Single.error(PITLinkingAPIError.unknown)
                }
                
                return Single.just(endpoint)
            })
    }
    
    var nabuUser: Observable<NabuUser> {
        return Observable<Int>.interval(
            3,
            scheduler: MainScheduler.asyncInstance
        ).flatMap(weak: self, selector: { (self, _) -> Observable<NabuUser> in
            return self.blockchainRepository.fetchNabuUser().asObservable()
        })
    }
        
    func linkToExistingPitUser(linkID: LinkID) -> Completable {
        return authenticationService.getSessionToken().flatMapCompletable(weak: self, { (self, sessionToken) -> Completable in
            return self.client.linkToExistingPitUser(authenticationToken: sessionToken.token, linkID)
        })
    }
    
    private func percentEscapeString(_ stringToEscape: String) -> String {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        return stringToEscape
            .addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)?
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil) ?? stringToEscape
    }
}
