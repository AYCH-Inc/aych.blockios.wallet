//
//  ResultExtensions.swift
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

extension Result {
    public var maybe: Maybe<Success> {
        switch self {
        case .success(let value):
            return Maybe.just(value)
        case .failure:
            return Maybe.empty()
        }
    }
}

extension Result where Failure == Never {
    public func flatMapError<E: Error>(to type: E.Type) -> Result<Success, E> {
        return flatMapError()
    }
    
    public func flatMapError<E: Error>() -> Result<Success, E> {
        return flatMapError { _ -> Result<Success, E> in
            fatalError("This can never be executed")
        }
    }
}

extension Result where Success == Never {
    public func flatMapSuccess<T>() -> Result<T, Failure> {
        return flatMap { _ -> Result<T, Failure> in
            fatalError("This can never be executed")
        }
    }
}
