//
//  Rx+BottomAlertSheet.swift
//  PlatformUIKit
//
//  Created by AlexM on 7/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Show the loader and returns `Element`
    func showSheetAfterSuccess(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        return self.do(afterSuccess: { _ in
            bottomAlertSheet.show()
        })
    }
    
    /// Show the loader and returns `Element`
    func showSheetAfterFailure(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        return self.do(afterError: { _ in
            bottomAlertSheet.show()
        })
    }
    
    /// Show the loader and returns `Element`
    func showSheetOnSubscription(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        return self.do(onSubscribe: {
            bottomAlertSheet.show()
        })
    }
    
    /// Hides the loader and returns `Element`
    func hideBottomSheetOnDisposal(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        return self.do(onDispose: {
            bottomAlertSheet.hide()
        })
    }
    
    /// Hides the loader and returns `Element`
    func hideBottomSheetOnSuccessOrError(bottomAlertSheet: BottomAlertSheet) -> Single<Element> {
        return self.do(onSuccess: { _ in
            bottomAlertSheet.hide()
        }, onError: { _ in
            bottomAlertSheet.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {
    
    /// Shows the loader upon subscription
    func showSheetOnSubscription(bottomAlertSheet: BottomAlertSheet) -> Observable<Element> {
        return self.do(onSubscribe: {
            bottomAlertSheet.show()
        })
    }
    
    /// Hides the loader upon disposal
    func hideBottomSheetOnDisposal(bottomAlertSheet: BottomAlertSheet) -> Observable<Element> {
        return self.do(onDispose: {
            bottomAlertSheet.hide()
        })
    }
}
