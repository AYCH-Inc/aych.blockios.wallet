//
//  PasswordAccessAPI.swift
//  PlatformKit
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public typealias Password = String

public protocol PasswordAccessAPI {
    var password: Maybe<Password> { get }
}
