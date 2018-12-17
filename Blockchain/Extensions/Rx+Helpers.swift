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
    func optional() -> Observable<E?> {
        return self.asObservable().map { e -> E? in
            return e
        }
    }
}

extension PrimitiveSequenceType where TraitType == SingleTrait {
    func optional() -> Single<ElementType?> {
        return self.map { e -> ElementType? in
            return e
        }
    }
}
