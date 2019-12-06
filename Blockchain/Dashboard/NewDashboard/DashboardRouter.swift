//
//  DashboardRouter.swift
//  Blockchain
//
//  Created by AlexM on 11/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

final class DashboardRouter {
    
    private let disposeBag = DisposeBag()
    private let currencyRouting: CurrencyRouting
    private let tabSwapping: TabSwapping
    private let rootViewController: TabViewController!
    private let dataProvider: DataProvider
    
    init(rootViewController: TabViewController,
         currencyRouting: CurrencyRouting,
         tabSwapping: TabSwapping,
         dataProvider: DataProvider = DataProvider.default) {
        self.rootViewController = rootViewController
        self.dataProvider = dataProvider
        self.currencyRouting = currencyRouting
        self.tabSwapping = tabSwapping
    }
    
    func showDetailsScreen(for currency: CryptoCurrency) {
        let balanceFetcher = dataProvider.balance[currency]
        let detailsInteractor = DashboardDetailsScreenInteractor(
            currency: currency,
            service: balanceFetcher,
            currencyProvider: BlockchainSettings.App.shared,
            exchangeAPI: dataProvider.exchange[currency]
        )
        let detailsPresenter = DashboardDetailsScreenPresenter(
            using: detailsInteractor,
            with: currency,
            currencyCode: BlockchainSettings.App.shared.fiatCurrencyCode
        )
        
        detailsPresenter.action
            .emit(onNext: { [weak self] action in
                guard let self = self else { return }
                self.handle(action: action)
            })
            .disposed(by: disposeBag)
        
        let controller = DashboardDetailsViewController(using: detailsPresenter)
        if #available(iOS 13.0, *) {
            rootViewController.present(controller, animated: true, completion: nil)
        } else {
            let navController = BaseNavigationController(rootViewController: controller)
            rootViewController.present(navController, animated: true, completion: nil)
        }
    }
    
    private func handle(action: DashboadDetailsAction) {
        // TODO: Inject `Currency`
        rootViewController.dismiss(animated: true, completion: nil)
        switch action {
        case .buy(let currency):
            break
        case .request(let currency):
            currencyRouting.toReceive(currency)
        case .send(let currency):
            currencyRouting.toSend(currency)
        case .swap(let currency):
            tabSwapping.switchTabToSwap()
        }
    }
}
