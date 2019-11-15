//
//  SessionTokenClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 15/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SessionTokenClientAPI: class {
    /// A Single that streams the session token
    var token: Single<String> { get }
}
