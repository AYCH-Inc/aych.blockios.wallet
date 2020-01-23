//
//  BadgeAssetInteracting.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

protocol BadgeAssetInteracting {
    var state: Observable<BadgeAsset.State.BadgeItem.Interaction> { get }
}
