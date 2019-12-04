//
//  MultiActionViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformUIKit

/// `MultiActionViewPresenting` represents a `MultiActionView`.
/// There are two types, `primary` as well as `default`.
/// They both use different `SegmentedViewModel` stylings.
protocol MultiActionViewPresenting {
    /// The view model for the `SegmentedView`
    var segmentedViewModel: SegmentedViewModel { get }
}

final class PrimaryActionViewPresenter: MultiActionViewPresenting {
    
    var segmentedViewModel: SegmentedViewModel

    // MARK: - Setup
    
    init(using items: [SegmentedViewModel.Item]) {
        self.segmentedViewModel = .primary(items: items)
    }
}

final class PlainActionViewPresenter: MultiActionViewPresenting {
    
    var segmentedViewModel: SegmentedViewModel

    // MARK: - Setup
    
    init(using items: [SegmentedViewModel.Item]) {
        self.segmentedViewModel = .plain(items: items)
    }
}

final class DefaultActionViewPresenter: MultiActionViewPresenting {
    
    var segmentedViewModel: SegmentedViewModel

    // MARK: - Setup
    
    init(using items: [SegmentedViewModel.Item]) {
        if #available(iOS 13.0, *) {
            self.segmentedViewModel = .default(items: items, isMomentary: false)
        } else {
            self.segmentedViewModel = .legacy(items: items, isMomentary: false)
        }
    }
}
