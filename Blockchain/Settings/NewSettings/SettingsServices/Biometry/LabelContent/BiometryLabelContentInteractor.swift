//
//  BiometryLabelContentInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class BiometryLabelContentInteractor: LabelContentInteracting {
    
    typealias InteractionState = LabelContentAsset.State.LabelItem.Interaction
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    
    init(biometryProviding: BiometryProviding) {
        // TODO: Localization
        var title = LocalizationConstants.Settings.enableTouchID
        switch biometryProviding.supportedBiometricsType {
        case .faceId:
            title = LocalizationConstants.Settings.enableFaceID
        case .touchId:
            title = LocalizationConstants.Settings.enableTouchID
        case .none:
            break
        }
        stateRelay.accept(.loaded(next: .init(text: title)))
    }
}
