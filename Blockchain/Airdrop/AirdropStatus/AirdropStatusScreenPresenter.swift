//
//  AirdropStatusScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

final class AirdropStatusScreenPresenter {
    
    // MARK: - Types
    
    typealias LocalizedString = LocalizationConstants.Airdrop.StatusScreen
    typealias AccessibilityId = Accessibility.Identifier.AirdropStatusScreen
    
    // MARK: - Exposed Properties

    var backgroundImage: Driver<ImageViewContent> {
        return backgroundImageRelay.asDriver()
    }
    
    var image: Driver<ImageViewContent> {
        return imageRelay.asDriver()
    }
    
    var title: Driver<LabelContent> {
        return titleRelay.asDriver()
    }
    
    var description: Driver<LabelContent> {
        return descriptionRelay.asDriver()
    }
    
    var cellPresenters: Observable<[AirdropStatusCellPresenter]> {
        return cellPresentersRelay
            .observeOn(MainScheduler.instance)
    }
    
    var cellPresentersValue: [AirdropStatusCellPresenter] {
        return cellPresentersRelay.value
    }
    
    // MARK: - Private Relays
    
    private let backgroundImageRelay = BehaviorRelay(
        value: ImageViewContent(accessibility: .id(AccessibilityId.thumbImageView))
    )
    private let imageRelay = BehaviorRelay(
        value: ImageViewContent(accessibility: .id(AccessibilityId.thumbImageView))
    )
    private let titleRelay = BehaviorRelay(
        value: LabelContent(accessibility: .id(AccessibilityId.titleLabel))
    )
    private let descriptionRelay = BehaviorRelay(
        value: LabelContent(accessibility: .id(AccessibilityId.descriptionLabel))
    )
    private let cellPresentersRelay = BehaviorRelay<[AirdropStatusCellPresenter]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    let presentationType: PresentationType
    private let alertPresenter: AlertViewPresenter
    private let interactor: AirdropStatusScreenInteractor
    
    // MARK: - Setup
    
    init(presentationType: PresentationType,
         alertPresenter: AlertViewPresenter = .shared,
         interactor: AirdropStatusScreenInteractor) {
        self.alertPresenter = alertPresenter
        self.presentationType = presentationType
        self.interactor = interactor
        
        interactor.calculationState
            .bind { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .value(let campaign):
                    self.setupGeneralInfo(using: campaign)
                    self.setupCellPresenters(using: campaign)
                case .invalid(let error):
                    self.handle(error: error)
                case .calculating: // On calculation do nothing
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
        
    /// Setups the campaign
    private func setupCellPresenters(using campaign: AirdropCampaigns.Campaign) {
        var dataSource: [AirdropStatusCellData] = []
        
        // Drop user state
        let status: String
        switch campaign.currentState {
        case .claimed:
            status = LocalizedString.Cell.Status.claimed
        case .notRegistered:
            status = LocalizedString.Cell.Status.notRegistered
        case .enrolled:
            status = LocalizedString.Cell.Status.enrolled
        case .received:
            status = LocalizedString.Cell.Status.received
        case .ineligible:
            status = LocalizedString.Cell.Status.failed
        case .expired:
            status = LocalizedString.Cell.Status.expired
        }
        
        dataSource.append(
            AirdropStatusCellData(
                title: .init(
                    text: LocalizedString.Cell.Status.label,
                    accessibility: .id(AccessibilityId.Cell.Status.title)
                ),
                value: .init(
                    text: status,
                    accessibility: .id(AccessibilityId.Cell.Status.value)
                )
            )
        )
        
        // Drop date
        if let date = campaign.dropDate {
            let formatter = DateFormatter.ddMMyyyy(separatedBy: "/")
            let date = formatter.string(from: date)
            dataSource.append(
                AirdropStatusCellData(
                    title: .init(
                        text: LocalizedString.Cell.date,
                        accessibility: .id(AccessibilityId.Cell.Date.title)
                    ),
                    value: .init(
                        text: date,
                        accessibility: .id(AccessibilityId.Cell.Date.value)
                    )
                )
            )
        }
        
        // Drop amount
        if let transaction = campaign.latestTransaction {
            var amount = String(
                format: LocalizedString.Cell.Amount.value,
                transaction.withdrawalCurrency,
                transaction.fiat.toDisplayString(includeSymbol: false),
                transaction.fiatCurrency
            )
            
            /// Prepend either the crypto amount if exists, or a placeholder otherwise
            let crypto = transaction.crypto?.toDisplayString(includeSymbol: false) ?? LocalizedString.Cell.Amount.valuePlaceholder
            amount = crypto + amount

            dataSource.append(
                AirdropStatusCellData(
                    title: .init(
                        text: LocalizedString.Cell.Amount.label,
                        accessibility: .id(AccessibilityId.Cell.Amount.title)
                    ),
                    value: .init(
                        text: amount,
                        accessibility: .id(AccessibilityId.Cell.Amount.value)
                    )
                )
            )
        }

        cellPresentersRelay.accept(
            dataSource.map { AirdropStatusCellPresenter(data: $0) }
        )
    }
    
    private func setupGeneralInfo(using campaign: AirdropCampaigns.Campaign) {
        guard let campaignName = AirdropCampaigns.Campaign.Name(rawValue: campaign.name) else {
            return
        }
        
        let title: String
        let description: String
        let image: UIImage
        
        switch campaignName {
        case .blockstack:
            title = LocalizedString.Blockstack.title
            description = LocalizedString.Blockstack.description
            image = TriageCryptoCurrency.blockstack.logoImage
        case .sunriver:
            image = CryptoCurrency.stellar.logo
            title = LocalizedString.Stellar.title
            description = LocalizedString.Stellar.description
        }

        titleRelay.accept(
            .init(
                text: title,
                font: .mainSemibold(20),
                color: .titleText,
                accessibility: .id(AccessibilityId.titleLabel)
            )
        )
        
        descriptionRelay.accept(
            .init(
                text: description,
                font: .mainMedium(14),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.descriptionLabel)
            )
        )
        
        imageRelay.accept(
            ImageViewContent(
                image: image,
                accessibility: .id(AccessibilityId.thumbImageView)
            )
        )
    }
    
    private func handle(error: ValueCalculationState<AirdropCampaigns.Campaign>.CalculationError) {
        switch error {
        case .empty:
            break
        case .valueCouldNotBeCalculated:
            self.alertPresenter.standardError(
                message: LocalizationConstants.GeneralError.loadingData
            )
        }
    }
}
