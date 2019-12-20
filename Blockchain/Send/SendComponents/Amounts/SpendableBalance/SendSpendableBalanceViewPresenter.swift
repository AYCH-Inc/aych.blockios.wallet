//
//  SendSpendableBalanceViewPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

/// Presentation layer for spendable balance cell on send screen
final class SendSpendableBalanceViewPresenter {
    
    // MARK: - Exposed Properties
    
    /// An attributed string that visualize the spendable balance
    /// Streams on the main thread and replays the latest value.
    var attributedString: Driver<NSAttributedString> {
        return attributesStringRelay.asDriver()
    }
    
    /// Tap receiver
    let tapRelay = PublishRelay<Void>()
    
    /// Streams the max spendable balance upon interaction
    let spendableBalanceTap: Observable<FiatCryptoPair>

    // MARK: - Private Properties
    
    private let attributesStringRelay = BehaviorRelay<NSAttributedString>(value: NSAttributedString())
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let interactor: SendSpendableBalanceInteracting
    private let analyticsRecorder: AnalyticsEventRelayRecording
    
    // MARK: - Setup
    
    init(asset: AssetType,
         interactor: SendSpendableBalanceInteracting,
         analyticsRecorder: AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        self.interactor = interactor
        self.analyticsRecorder = analyticsRecorder
        
        tapRelay
            .map { AnalyticsEvents.Send.sendFormUseBalanceClick(asset: asset) }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        spendableBalanceTap = tapRelay.withLatestFrom(interactor.balance)
        
        // Construct the attributed string for the crypto balance
        interactor.balance
            .map { $0.crypto }
            .map { $0.toDisplayString(includeSymbol: true) }
            .map { value -> NSAttributedString in
                let font = Font(
                    .branded(.montserratRegular),
                    size: .custom(13.0)
                ).result
                
                // Setup prefix
                let prefixAttributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.darkGray
                ]
                let text = NSMutableAttributedString(
                    string: LocalizationConstants.Send.SpendableBalance.prefix,
                    attributes: prefixAttributes
                )
                
                // Setup suffix
                let suffixAttributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.brandSecondary
                ]
                let suffix = NSAttributedString(
                    string: value,
                    attributes: suffixAttributes
                )
                text.append(suffix)
                return text
            }
            .bind(to: attributesStringRelay)
            .disposed(by: disposeBag)
    }
}
