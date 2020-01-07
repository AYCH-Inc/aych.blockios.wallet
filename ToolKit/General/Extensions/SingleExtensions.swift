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
    public func map<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> R) -> PrimitiveSequence<SingleTrait, R> {
        return map { [weak object] element -> R in
            guard let object = object else { throw ToolKitError.nullReference(A.self) }
            return try selector(object, element)
        }
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    public func flatMap<A: AnyObject>(weak object: A, _ selector: @escaping (A) throws -> Completable) -> Completable {
        do {
            return asObservable().ignoreElements().andThen(try selector(object))
        } catch {
            return .error(error)
        }
    }
    
    /// Convert from `Completable` into `Single`
    public func flatMapSingle<A: AnyObject, R>(weak object: A, _ selector: @escaping (A) throws -> Single<R>) -> Single<R> {
        do {
            return asObservable().ignoreElements().andThen(try selector(object))
        } catch {
            return .error(error)
        }
    }
}

extension ObservableType {
    public static func create<A: AnyObject>(weak object: A, subscribe: @escaping (A, (AnyObserver<Element>)) -> Disposable) -> Observable<Element> {
        return Observable<Element>.create { [weak object] observer -> Disposable in
            guard let object = object else {
                observer.on(.error(ToolKitError.nullReference(A.self)))
                return Disposables.create()
            }
            return subscribe(object, observer)
        }
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
    
    public static func create<A: AnyObject>(weak object: A, subscribe: @escaping (A, @escaping SingleObserver) -> Disposable) -> Single<Element> {
        return Single<Element>.create { [weak object] observer -> Disposable in
            guard let object = object else {
                observer(.error(ToolKitError.nullReference(A.self)))
                return Disposables.create()
            }
            return subscribe(object, observer)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func recordErrors(on recorder: Recording?, enabled: Bool = true) -> Single<Element> {
        guard enabled else { return self }
        return self.do(onError: { error in
            recorder?.error(error)
        })
    }
}
