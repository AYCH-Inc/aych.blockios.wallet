//
//  SwitchCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift

protocol SwitchCellPresenting {
    var labelContentPresenting: LabelContentPresenting { get }
    var switchViewPresenting: SwitchViewPresenting { get }
}

class EmailNotificationsSwitchCellPresenter: SwitchCellPresenting {
    
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(service: EmailNotificationSettingsServiceAPI & SettingsServiceAPI) {
        labelContentPresenting = DefaultLabelContentPresenter(
            title: LocalizationConstants.Settings.emailNotifications,
            descriptors: .settings
        )
        switchViewPresenting = EmailSwitchViewPresenter(service: service)
    }
}

class BioAuthenticationSwitchCellPresenter: SwitchCellPresenting {
    
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(biometryProviding: BiometryProviding,
         appSettingsAuthenticating: AppSettingsAuthenticating) {
        labelContentPresenting = BiometryLabelContentPresenter(
            provider: biometryProviding,
            descriptors: .settings
        )
        switchViewPresenting = BiometrySwitchViewPresenter(settingsAuthenticating: appSettingsAuthenticating)
    }
}

class SwipeReceiveSwitchCellPresenter: SwitchCellPresenting {
    
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(appSettings: BlockchainSettings.App) {
        
        switchViewPresenting = SwipeReceiveSwitchViewPresenter(appSettings: appSettings)
        labelContentPresenting = DefaultLabelContentPresenter(
            title: LocalizationConstants.Settings.swipeToReceive,
            descriptors: .settings
        )
    }
}
