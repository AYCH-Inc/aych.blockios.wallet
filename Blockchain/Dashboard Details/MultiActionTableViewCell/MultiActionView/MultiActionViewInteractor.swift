//
//  MultiActionViewInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class MultiActionViewInteractor: MultiActionViewInteracting {
    
    let items: [SegmentedViewModel.Item]
    
    init(items: [SegmentedViewModel.Item]) {
        self.items = items
    }
}
