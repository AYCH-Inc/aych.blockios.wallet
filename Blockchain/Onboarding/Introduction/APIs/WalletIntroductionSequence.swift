//
//  WalletIntroductionSequence.swift
//  Blockchain
//
//  Created by AlexM on 8/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// A sequence of WalletIntroductionEvent models
struct WalletIntroductionSequence: Sequence, IteratorProtocol {
    
    // MARK: - Properties
    
    private var index = 0
    private var announcements: [WalletIntroductionEvent]
    
    // MARK: - Setup
    
    init(announcements: [WalletIntroductionEvent] = []) {
        self.announcements = announcements
    }
    
    // MARK: - Sequence
    
    /// Computes the next introduction event
    mutating func next() -> WalletIntroductionEvent? {
        let index = announcements.firstIndex { $0.shouldShow }
        if let index = index {
            self.index = index
            return announcements.remove(at: index)
        }
        return nil
    }
    
    // MARK: - Accessors
    
    /// Resets the sequence to a given `WalletIntroductionEvent` array
    mutating func reset(to announcements: [WalletIntroductionEvent]) {
        self.index = 0
        self.announcements = announcements
    }
}

protocol WalletIntroductionLocationSequenceAPI {
    /// Returns the next location given a location. 
    func nextLocation(from location: WalletIntroductionLocation) -> Single<WalletIntroductionLocation>
}

enum WalletIntroductionError: Error {
    case invalidScreenForStep
    case noAdditionalSteps
}

class WalletIntroductionLocationSequencer: WalletIntroductionLocationSequenceAPI {
    
    func nextLocation(from location: WalletIntroductionLocation) -> Single<WalletIntroductionLocation> {
        switch location.screen {
        case .sideMenu:
            /// The only introduction event with a location in the `SideMenu` is `.buySell`. There are no additional
            /// locations after this.
            return Single.error(WalletIntroductionError.noAdditionalSteps)
        case .dashboard:
            switch location.position {
            case .home:
                return Single.just(WalletIntroductionLocation(screen: .dashboard, position: .send))
            case .send:
                return Single.just(WalletIntroductionLocation(screen: .dashboard, position: .request))
            case .request:
                return Single.just(WalletIntroductionLocation(screen: .dashboard, position: .swap))
            case .swap:
                return Single.just(WalletIntroductionLocation(screen: .sideMenu, position: .buySell))
            case .buySell:
                return Single.error(WalletIntroductionError.noAdditionalSteps)
            }
        }
    }
}
