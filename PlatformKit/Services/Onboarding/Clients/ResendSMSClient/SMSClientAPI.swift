//
//  SMSClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Client API for SMS
public protocol SMSClientAPI: class {
    
    /// Requests the server to send a new OTP
    func requestOTP(sessionToken: String, guid: String) -> Completable
}
