//
//  ObservableType+Loading.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 12/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Shows the loader
    func show(loader: LoadingViewPresenting,
              text: String? = nil) -> Single<Element> {
        return self.do(onSuccess: { _ in
            loader.show(with: text)
        })
    }
    
    /// Hides the loader
    func hide(loader: LoadingViewPresenting,
              text: String? = nil) -> Single<Element> {
        return self.do(onSuccess: { _ in
            loader.hide()
        })
    }
    
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
    
    /// Shows and hides the loader
    func handleLoaderForLifecycle(loader: LoadingViewPresenting,
                                  text: String? = nil) -> Single<Element> {
        return self.do(onSubscribe: {
            loader.show(with: text)
        }, onDispose: {
            loader.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Show the loader and returns `Element`
    func show(loader: LoadingViewPresenting,
              style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
              text: String? = nil) -> Observable<Element> {
        return self.do(onNext: { _ in
            switch style {
            case .circle:
                loader.showCircular(with: text)
            case .activityIndicator:
                loader.show(with: text)
            }
        })
    }
    
    /// Hides the loader and returns `Element`
    func hide(loader: LoadingViewPresenting) -> Observable<Element> {
        return self.do(onNext: { _ in
            loader.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Shows and hides the loader
    func handleLoaderForLifecycle(loader: LoadingViewPresenting,
                                  text: String? = nil) -> Observable<Element> {
        return self.do(onSubscribe: {
            loader.show(with: text)
        }, onDispose: {
            loader.hide()
        })
    }
    
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
              style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
              text: String? = nil) -> Completable {
        return Completable.create { completable -> Disposable in
            switch style {
            case .circle:
                loader.showCircular(with: text)
            case .activityIndicator:
                loader.show(with: text)
            }
            
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
