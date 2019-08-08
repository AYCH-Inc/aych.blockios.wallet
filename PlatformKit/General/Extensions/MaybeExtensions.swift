//
//  MaybeExtensions.swift
//  PlatformKit
//
//  Created by Jack on 01/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

extension Maybe {
    public func flatMap<A: AnyObject,R>(weak object: A, _ selector: @escaping (A, Element) throws -> Maybe<R>) -> Maybe<R> {
        return asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asMaybe()
    }
}
