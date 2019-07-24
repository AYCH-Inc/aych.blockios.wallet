//
//  ObservableType+Loading.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 12/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Show the loader and returns `Element`
    func showOnSubscription(loader: LoadingViewPresenting,
              text: String? = nil) -> Single<Element> {
        return self.do(onSubscribe: {
            loader.show(with: text)
        })
    }
    
    /// Hides the loader and returns `Element`
    func hideOnDisposal(loader: LoadingViewPresenting) -> Single<Element> {
        return self.do(onDispose: {
            loader.hide()
        })
    }
}


/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Show the loader and returns `Element`
    func show(loader: LoadingViewPresenting,
              text: String? = nil) -> Observable<Element> {
        loader.show(with: text)
        return map { $0 }
    }
    
    /// Hides the loader and returns `Element`
    func hide(loader: LoadingViewPresenting) -> Observable<Element> {
        loader.hide()
        return map { $0 }
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Shows the loader upon subscription
    func showLoaderOnSubscription(loader: LoadingViewPresenting,
                                  text: String? = nil) -> Observable<Element> {
        return self.do(onSubscribe: {
            loader.show(with: text)
        })
    }
    
    /// Hides the loader upon disposal
    func hideLoaderOnDisposal(loader: LoadingViewPresenting) -> Observable<Element> {
        return self.do(onDispose: {
            loader.hide()
        })
    }
}

/// Extension for any component that inherits `ReactiveLoaderPresenting`.
/// Enables Rx for displaying and hiding the loader
public extension Reactive where Base: ReactiveLoaderPresenting {
    
    /// Show the loader and returns `Element`
    func show(loader: LoadingViewPresenting,
              text: String? = nil) -> Completable {
        return Completable.create { completable -> Disposable in
            loader.show(with: text)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    /// Show the loader and returns `Element`
    func hide(loader: LoadingViewPresenting) -> Completable {
        return Completable.create { completable -> Disposable in
            loader.hide()
            completable(.completed)
            return Disposables.create()
        }
    }
}
