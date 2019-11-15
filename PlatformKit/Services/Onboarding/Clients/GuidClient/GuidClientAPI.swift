//
//  GuidClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 15/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// A `GUID` client API. A concrete type is expected to fetch the `GUID`
public protocol GuidClientAPI: class {
    /// A `Single` that streams the `GUID` on success or fails due
    /// to a missing resource or network error.
    var guid: Single<String> { get }
}
