//
//  PaxActivityServiceAPI.swift
//  Blockchain
//
//  Created by AlexM on 5/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ERC20Kit

class PaxActivityServiceAPI: SimpleListServiceAPI {
    
    // MARK: - Services
    
    private let cache: ERC20HistoricalTransactionCaching<PaxToken>
    private let transactionService: AnyERC20HistoricalTransactionService<PaxToken>
    private let loadingViewPresenter: LoadingViewPresenting
    private let analyticsRecorder: AnalyticsEventRecording
    
    private var disposable: Disposable?
    private var internalModel: InternalModel?
    
    struct InternalModel {
        let responses: [PageResult<ERC20HistoricalTransaction<PaxToken>>]
    }
    
    init(provider: PAXServiceProvider = PAXServiceProvider.shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.transactionService = provider.services.historicalTransactionService
        self.cache = ERC20HistoricalTransactionCaching<PaxToken>()
        self.loadingViewPresenter = loadingViewPresenter
        self.analyticsRecorder = analyticsRecorder
    }
    
    func fetchAllItems(output: SimpleListOutput?) {
        disposable = transactionService.fetchTransactions(token: "0", size: 50)
            .map { $0 }
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [weak self] in
                self?.disposable = nil
            })
            .subscribe(onSuccess: { result in
                self.internalModel = InternalModel(responses: self.internalModel?.responses ?? [] + [result])
                output?.loadedItems(result.items)
            }, onError: { error in
                output?.itemFetchFailed(error: error)
            })
    }
    
    func refresh(output: SimpleListOutput?) {
        fetchAllItems(output: output)
    }
    
    func fetchDetails(for item: Identifiable, output: SimpleListOutput?) {
        guard let model = item as? ERC20HistoricalTransaction<PaxToken> else { return }
        
        loadingViewPresenter.show(with: LocalizationConstants.loading)
        
        let code = BlockchainSettings.App.shared.fiatCurrencyCode
        disposable = cache.item(with: model.transactionHash).ifEmpty(
            switchTo: model.fetchTransactionDetails(currencyCode: code)
            )
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [weak self] in
                guard let self = self else { return }
                self.loadingViewPresenter.hide()
                self.disposable = nil
            })
            .subscribe(onSuccess: { [weak self] newModel in
                guard let self = self else { return }
                self.cache.save(newModel, key: newModel.transactionHash)
                self.analyticsRecorder.record(
                    event: AnalyticsEvents.Transactions.transactionsListItemClick(asset: .pax)
                )
                output?.showItemDetails(newModel)
            }, onError: { error in
                Logger.shared.error(error)
            })
    }
    
    func nextPageBefore(identifier: String, output: SimpleListOutput?) {
        guard isExecuting() == false else { return }
        guard let model = internalModel else { return }
        guard canPage() == true else { return }
        output?.willApplyUpdate()
        disposable = transactionService.fetchTransactions(token: String(model.responses.count), size: 50)
            .map { $0 }
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [weak self] in
                self?.disposable = nil
            })
            .subscribe(onSuccess: { result in
                self.internalModel = InternalModel(responses: self.internalModel?.responses ?? [] + [result])
                output?.appendItems(result.items)
                output?.didApplyUpdate()
            }, onError: { error in
                output?.itemFetchFailed(error: error)
                output?.didApplyUpdate()
            })
    }
    
    func cancel() {
        disposable?.dispose()
        disposable = nil
    }
    
    func isExecuting() -> Bool {
        return disposable != nil
    }
    
    func canPage() -> Bool {
        guard isExecuting() == false else { return false }
        guard let model = internalModel else { return false }
        guard let last = model.responses.last else { return false }
        return last.hasNextPage
    }
    
    deinit {
        disposable?.dispose()
        disposable = nil
    }
    
}
