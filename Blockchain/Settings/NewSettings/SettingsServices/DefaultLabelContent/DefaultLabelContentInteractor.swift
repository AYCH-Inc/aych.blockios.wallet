//
//  DefaultLabelContentInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class DefaultLabelContentInteractor: LabelContentInteracting {
    
    typealias InteractionState = LabelContentAsset.State.LabelItem.Interaction
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(value: String) {
        stateRelay.accept(.loaded(next: .init(text: value)))
    }
}
