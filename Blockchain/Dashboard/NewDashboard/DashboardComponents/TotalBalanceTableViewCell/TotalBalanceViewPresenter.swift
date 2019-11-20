//
//  TotalBalanceViewPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit

final class TotalBalanceViewPresenter {

    // MARK: - Properties

    let titleContent = LabelContent(
        text: LocalizationConstants.Dashboard.Balance.totalBalance,
        font: .mainMedium(16),
        color: .mutedText,
        accessibility: .init(
            id: .value(Accessibility.Identifier.Dashboard.TotalBalanceCell.titleLabel)
        )
    )
    
    // MARK: - Services
        
    let balancePresenter: AssetPriceViewPresenter
    let pieChartPresenter: AssetPieChartPresenter
    
    private let interactor: TotalBalanceViewInteractor
    
    // MARK: - Setup
    
    init(balanceProvider: BalanceProviding,
         balanceChangeProvider: BalanceChangeProviding) {
        let balanceInteractor = BalanceChangeViewInteractor(
            balanceProvider: balanceProvider,
            balanceChangeProvider: balanceChangeProvider
        )
        let chartInteractor = AssetPieChartInteractor(balanceProvider: balanceProvider)
        pieChartPresenter = AssetPieChartPresenter(
            edge: 88,
            interactor: chartInteractor
        )
        balancePresenter = AssetPriceViewPresenter(
            interactor: balanceInteractor,
            descriptors: .balance
        )
        interactor = TotalBalanceViewInteractor(
            chartInteractor: chartInteractor,
            balanceInteractor: balanceInteractor
        )
    }
}
