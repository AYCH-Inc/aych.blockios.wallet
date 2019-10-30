//
//  AirdropRegistrationMock.swift
//  BlockchainTests
//
//  Created by Jack on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
@testable import PlatformKit

class AirdropRegistrationMock: AirdropRegistrationAPI {
    
    var didCallSubmitRegistrationRequest: (AirdropRegistrationRequest) -> Void = { _ in }
    var registrationRequestValues: [AirdropRegistrationRequest] = []
    var submitRegistrationRequestValue: Single<AirdropRegistrationResponse> = Single.just(AirdropRegistrationResponse(message: "Success"))
    func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse> {
        didCallSubmitRegistrationRequest(registrationRequest)
        registrationRequestValues.append(registrationRequest)
        return submitRegistrationRequestValue
    }
    
}
