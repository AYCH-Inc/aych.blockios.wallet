//
//  UserInformationProvider.swift
//  PlatformKit
//
//  Created by Daniel Huri on 24/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol UserInformationServiceProviding: class {
    var settings: SettingsServiceAPI & EmailSettingsServiceAPI & LastTransactionSettingsUpdateServiceAPI & EmailNotificationSettingsServiceAPI { get }
    var emailVerification: EmailVerificationServiceAPI { get }
}
