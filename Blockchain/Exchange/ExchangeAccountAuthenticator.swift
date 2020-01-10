//
//  ExchangeAccountAuthenticator.swift
//  Blockchain
//
//  Created by AlexM on 7/15/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit
import NetworkKit
import PlatformKit

protocol ExchangeAccountAuthenticatorAPI {
    typealias LinkID = String
    var exchangeLinkID: Single<LinkID> { get }
    var exchangeURL: Single<URL> { get }
    var nabuUser: Observable<NabuUser> { get }
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable
}

class ExchangeAccountAuthenticator: ExchangeAccountAuthenticatorAPI {
    
    private let blockchainRepository: BlockchainDataRepository
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: ExchangeClientAPI
    private let campaignComposer: CampaignComposer
    
    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         campaignComposer: CampaignComposer = CampaignComposer(),
         clientAPI: ExchangeClientAPI = ExchangeClient(communicatorAPI: NetworkCommunicator.shared)) {
        self.blockchainRepository = blockchainRepository
        self.authenticationService = authenticationService
        self.campaignComposer = campaignComposer
        self.client = clientAPI
    }
    
    var exchangeLinkID: Single<LinkID> {
        return authenticationService.getSessionToken()
            .flatMap(weak: self, { (self, sessionToken) -> Single<LinkID> in
                return self.client.linkID(sessionToken.token)
            })
    }
    
    var exchangeURL: Single<URL> {
        return Single
            .zip(blockchainRepository.fetchNabuUser(), exchangeLinkID)
            .flatMap(weak: self, { (self, payload) -> Single<URL> in
                let user = payload.0
                let linkID = payload.1
                
                let email = self.percentEscapeString(user.email.address)
                guard let apiURL = URL(string: BlockchainAPI.shared.exchangeURL) else {
                    return Single.error(ExchangeLinkingAPIError.unknown)
                }
                
                let pathComponents = ["trade", "link", linkID]
                var queryParams = Dictionary(
                    uniqueKeysWithValues: self.campaignComposer.generalQueryValuePairs
                        .map { ($0.rawValue, $1.rawValue) }
                )
                queryParams += ["email": email]
                
                guard let endpoint = URL.endpoint(apiURL, pathComponents: pathComponents, queryParameters: queryParams) else {
                    return Single.error(ExchangeLinkingAPIError.unknown)
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
        
    func linkToExistingExchangeUser(linkID: LinkID) -> Completable {
        return authenticationService.getSessionToken().flatMapCompletable(weak: self, { (self, sessionToken) -> Completable in
            return self.client.linkToExistingExchangeUser(authenticationToken: sessionToken.token, linkID)
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
