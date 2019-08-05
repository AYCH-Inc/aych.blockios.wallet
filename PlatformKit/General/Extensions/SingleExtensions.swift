//
//  SingleExtensions.swift
//  PlatformKit
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension Single where Element: OptionalType {
    func onNil(error: Error) -> Single<Element.Wrapped> {
        // TODO: figure out how to implement this the right way
        return asObservable().onNil(error: error).asSingle()
    }
}

extension Single {
    public static func from<T, U: Error>(block: @escaping (@escaping (Swift.Result<T, U>) -> Void) -> Void) -> Single<T> {
        return Single.create(subscribe: { observer -> Disposable in
            block { result in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create()
        })
    }
}

extension Single {
    public func flatMap<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> Single<R>) -> Single<R> {
        return asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asSingle()
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func flatMapCompletable<A: AnyObject>(weak object: A, _ selector: @escaping (A, Element) throws -> Completable)
        -> Completable {
        return asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asCompletable()
    }
}
