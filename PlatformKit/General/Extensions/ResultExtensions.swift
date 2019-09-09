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
    public func mapError<E: Error>(to type: E.Type) -> Result<Success, E> {
        return mapError()
    }
    
    public func mapError<E: Error>() -> Result<Success, E> {
        return mapError { _ -> E in
            fatalError("This can never be executed")
        }
    }
}

extension Result where Success == Never {
    public func map<T>(to type: T.Type) -> Result<T, Failure> {
        return map()
    }
    
    public func map<T>() -> Result<T, Failure> {
        return map { _ in
            fatalError("This can never be executed")
        }
    }
}
