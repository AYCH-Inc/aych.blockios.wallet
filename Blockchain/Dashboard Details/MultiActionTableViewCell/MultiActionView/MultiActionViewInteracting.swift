//
//  MultiActionViewInteracting.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

protocol MultiActionViewInteracting {
    /// Items that can be selected in the `SegmentedView`.
    /// Each item has a closure that can be executed.
    var items: [SegmentedViewModel.Item] { get }
}
