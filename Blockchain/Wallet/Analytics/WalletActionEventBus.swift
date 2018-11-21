//
//  WalletActionEventBus.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

typealias WalletActionEventExtras = [WalletAction.ExtraKeys: Any]

struct WalletActionEvent {
    let action: WalletAction
    let extras: WalletActionEventExtras?
}

extension WalletAction {
    enum ExtraKeys: String, CaseIterable {
        case assetType
    }
}

/// An event bus the emits `WalletAction` events.
///
/// Whenever a wallet action is performed, for example when the user sends crypto,
/// an event should be emitted in this event bus by the component performing that action
/// by calling the `publish(action:extras)` method.
///
/// Components that are interested in listening to those events can then subscribe
/// to listen to emissions by subscribing to the `event` property.
@objc class WalletActionEventBus: NSObject {
    static let shared = WalletActionEventBus()

    @objc class func sharedInstance() -> WalletActionEventBus {
        return shared
    }

    private let publishSubject = PublishSubject<WalletActionEvent>()

    var events: Observable<WalletActionEvent> {
        return publishSubject.asObservable()
    }

    @objc func publishObj(action: WalletAction, extras: [String: Any]? = nil) {
        guard let extras = extras else {
            publish(action: action)
            return
        }
        var actionExtras = [WalletAction.ExtraKeys: Any]()
        extras.forEach { key, value in
            guard let extraKey = WalletAction.ExtraKeys(rawValue: key) else { return }
            actionExtras[extraKey] = value
        }
        publish(action: action, extras: actionExtras)
    }

    func publish(action: WalletAction, extras: WalletActionEventExtras? = nil) {
        publishSubject.onNext(WalletActionEvent(action: action, extras: extras))
    }
}
