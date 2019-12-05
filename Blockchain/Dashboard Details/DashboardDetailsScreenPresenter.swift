//
//  DashboardDetailsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

/// This enum aggregates possible action types that can be done in the dashboard
enum DashboadDetailsAction {
    case send(CryptoCurrency)
    case request(CryptoCurrency)
    case buy(CryptoCurrency)
    case swap(CryptoCurrency)
}

final class DashboardDetailsScreenPresenter {
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        return .none
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        return .close
    }
    
    var titleView: Screen.Style.TitleView {
        return .text(value: currency.description)
    }
    
    var barStyle: Screen.Style.Bar {
        return .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
    }
    
    // MARK: - Types
    
    enum CellType: Hashable {
        case balance
        case sendRequest
        case priceAlert
        case chart
    }
    
    // MARK: - Rx
    
    var isScrollEnabled: Driver<Bool> {
        return scrollingEnabledRelay.asDriver()
    }
    
    private let scrollingEnabledRelay = BehaviorRelay(value: false)
    
    // MARK: - Exposed Properties
    
    /// The dashboard action
    var action: Signal<DashboadDetailsAction> {
        return actionRelay.asSignal()
    }
    
    /// Returns the total count of cells
    var cellCount: Int {
        return cellArrangement.count
    }
    
    /// Returns the ordered cell types
    var cellArrangement: [CellType] {
        return [.balance,
                .sendRequest,
                .priceAlert,
                .chart]
    }
    
    var indexByCellType: [CellType: Int] {
        var indexByCellType: [CellType: Int] = [:]
        for (index, cellType) in cellArrangement.enumerated() {
            indexByCellType[cellType] = index
        }
        return indexByCellType
    }
    
    // MARK: - Public Properties (Presenters)
    
    var assetBalanceViewPresenter: AssetBalanceViewPresenter {
        return AssetBalanceViewPresenter(
            alignment: .trailing,
            interactor: AssetBalanceViewInteractor(assetBalanceFetching: interactor.balanceFetching)
        )
    }
    
    var sendRequestPresenter: MultiActionViewPresenting {
        return PlainActionViewPresenter(
            using: sendRequestItems
        )
    }
    
    let swapButtonViewModel: ButtonViewModel
    
    let lineChartCellPresenter: AssetLineChartTableViewCellPresenter
    
    let currency: CryptoCurrency
    
    // MARK: - Private Properties
    
    private let interactor: DashboardDetailsScreenInteracting
    private let actionRelay = PublishRelay<DashboadDetailsAction>()
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(using interactor: DashboardDetailsScreenInteracting,
         with currency: CryptoCurrency,
         currencyProvider: FiatCurrencyTypeProviding = BlockchainSettings.App.shared,
         currencyCode: String) {
        self.currency = currency
        self.interactor = interactor
        
        lineChartCellPresenter = AssetLineChartTableViewCellPresenter(
            currency: currency,
            currencyCode: currencyCode,
            historicalFiatPriceService: interactor.priceServiceAPI
        )
        
        lineChartCellPresenter.isScrollEnabled
            .drive(scrollingEnabledRelay)
            .disposed(by: disposeBag)
        
        swapButtonViewModel = .primary(with: LocalizationConstants.Swap.swap)
        swapButtonViewModel.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.actionRelay.accept(.swap(self.currency))
            }
            .disposed(by: disposeBag)
    }
    
    /// Should be called each time the dashboard view shows
    /// to trigger dashboard re-render
    func refresh() {
        interactor.refresh()
    }
    
    private lazy var sendRequestItems: [SegmentedViewModel.Item] = {
        return [.text("Send", action: { [weak self] in
                    guard let self = self else { return }
                    self.actionRelay.accept(.send(self.currency))
                    }
                ),
                .text("Request", action: { [weak self] in
                    guard let self = self else { return }
                    self.actionRelay.accept(.request(self.currency))
                })]
    }()
}
