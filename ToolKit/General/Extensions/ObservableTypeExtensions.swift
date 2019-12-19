//
//  ObservableTypeExtensions.swift
//  PlatformKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

extension ObservableType where Element: OptionalType {
    func onNil(error: Error) -> Observable<Element.Wrapped> {
        return flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.error(error)
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}

extension ObservableType {
    public func map<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> R) -> Observable<R> {
        return map { [weak object] element -> R in
            guard let object = object else { throw ToolKitError.nullReference(A.self) }
            return try selector(object, element)
        }
    }
}

extension ObservableType {
    public func flatMap<A: AnyObject, R>(weak object: A, selector: @escaping (A, Self.Element) throws -> Observable<R>) -> Observable<R> {
        return flatMap { [weak object] (value) -> Observable<R> in
            guard let object = object else {
                return Observable.error(ToolKitError.nullReference(A.self))
            }
            return try selector(object, value)
        }
    }

    public func flatMapLatest<A: AnyObject, R>(weak object: A, selector: @escaping (A, Self.Element) throws -> Observable<R>) -> Observable<R> {
        return flatMapLatest { [weak object] (value) -> Observable<R> in
            guard let object = object else {
                return Observable.error(ToolKitError.nullReference(A.self))
            }
            return try selector(object, value)
        }
    }
}
