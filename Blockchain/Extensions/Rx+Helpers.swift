//
//  Rx+Helpers.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

extension CompositeDisposable {
    @discardableResult func insertWithDiscardableResult(_ disposable: Disposable) -> CompositeDisposable.DisposeKey? {
        return self.insert(disposable)
    }
}

extension ObservableType {
    func optional() -> Observable<Element?> {
        return self.asObservable().map { e -> Element? in
            return e
        }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    func optional() -> Single<Element?> {
        return self.map { e -> Element? in
            return e
        }
    }
    
    func mapToVoid() -> Single<Void> {
        return map { _ in return () }
    }
}
