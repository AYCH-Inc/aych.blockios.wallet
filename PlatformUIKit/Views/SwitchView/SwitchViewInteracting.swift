//
//  SwitchViewInteracting.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public protocol SwitchViewInteracting {
    var state: Observable<LoadingState<SwitchInteractionAsset>> { get }
    var switchTriggerRelay: PublishRelay<Bool> { get }
}
