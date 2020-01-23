//
//  BackupFundsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class BackupFundsScreenPresenter {
    
    var subtitle: LabelContent {
        return .init(
            text: LocalizationConstants.BackupFundsScreen.subtitle,
            font: .mainSemibold(20.0),
            color: .textFieldText,
            accessibility: .none
        )
    }
    
    var primaryDescription: LabelContent {
        return .init(
            text: LocalizationConstants.BackupFundsScreen.Description.partA,
            font: .mainMedium(14.0),
            color: .textFieldText,
            accessibility: .none
        )
    }
    
    var secondaryDescription: LabelContent {
        return .init(
            text: LocalizationConstants.BackupFundsScreen.Description.partB,
            font: .mainMedium(14.0),
            color: .textFieldText,
            accessibility: .none
        )
    }
    
    let startBackupButton: ButtonViewModel
    
    // MARK: - Private Properties
    
    private let router: BackupFundsRouterAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(router: BackupFundsRouterAPI) {
        self.router = router
        self.startBackupButton = .primary(with: LocalizationConstants.BackupFundsScreen.startBackup)
        self.startBackupButton.tapRelay
            .bind { _ in
                router.startBackup()
            }
        .disposed(by: self.disposeBag)
    }
}
