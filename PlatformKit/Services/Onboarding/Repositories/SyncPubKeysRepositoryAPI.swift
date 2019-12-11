//
//  SyncPubKeysRepositoryAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 02/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SyncPubKeysRepositoryAPI: class {
    func set(syncPubKeys: Bool) -> Completable
}
