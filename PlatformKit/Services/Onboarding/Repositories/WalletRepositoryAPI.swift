//
//  WalletRepositoryAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 02/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol WalletRepositoryAPI: SessionTokenRepositoryAPI,
                                     SharedKeyRepositoryAPI,
                                     PasswordRepositoryAPI,
                                     GuidRepositoryAPI,
                                     SyncPubKeysRepositoryAPI,
                                     LanguageRepositoryAPI,
                                     AuthenticatorRepositoryAPI,
                                     PayloadRepositoryAPI {}
