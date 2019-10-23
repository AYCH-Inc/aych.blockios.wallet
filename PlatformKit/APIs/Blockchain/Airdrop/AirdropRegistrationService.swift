//
//  AirdropRegistrationService.swift
//  PlatformKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol AirdropRegistrationAPI {
    func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse>
}

public class AirdropRegistrationService: AirdropRegistrationAPI {
    
    private let client: APIClientAPI
    
    // MARK: - Setup
    
    // FIXME:
    // * Making this conveninence constructor `public` for now in an
    //   ideal world, the client would be provided by a `public` provider
    //   with internal properties
    public convenience init() {
        self.init(client: APIClient(config: .retailConfig))
    }
    
    init(client: APIClientAPI) {
        self.client = client
    }
    
    public func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse> {
        return client.submitRegistrationRequest(registrationRequest)
    }
}
