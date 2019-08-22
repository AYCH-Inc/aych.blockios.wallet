//
//  TransferSpendableBalanceCellPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

/// Presentation layer for spendable balance cell on transfer screen
final class TransferSpendableBalanceCellPresenter {
    
    // MARK: - Exposed Properties
    
    /// The attributed string that indicates the spendable balance
    var attributedString: Driver<NSAttributedString> {
        return attributesStringRelay.asDriver()
    }
    
    /// Tap receiver
    let tapRelay = PublishRelay<Void>()
    
    /// Streams the max spendable balance upon interaction
    let spendableBalanceTap: Observable<TransferredValue>
    
    // MARK: - Private Properties
    
    private let attributesStringRelay = BehaviorRelay<NSAttributedString>(value: NSAttributedString())
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let interactor: TransferSpendableBalanceInteracting
    
    // MARK: - Setup
    
    init(interactor: TransferSpendableBalanceInteracting) {
        self.interactor = interactor
        
        spendableBalanceTap = tapRelay.withLatestFrom(interactor.balance)
        
        // Bind balance to the attributed string
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
                    string: LocalizationConstants.Transfer.SpendableBalance.prefix,
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
