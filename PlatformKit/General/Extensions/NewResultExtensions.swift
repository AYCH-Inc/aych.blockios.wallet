//
//  NewResultExtensions.swift
//  PlatformKit
//
//  Created by Jack on 25/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

extension Result {
    public var single: Single<Success> {
        switch self {
        case .success(let value):
            return Single.just(value)
        case .failure(let error):
            return Single.error(error)
        }
    }
}
