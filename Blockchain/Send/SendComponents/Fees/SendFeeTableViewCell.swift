//
//  SendFeeTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PlatformUIKit

/// The fee cell on the send screen
final class SendFeeTableViewCell: UITableViewCell {

    // MARK: - UI Properties
    
    @IBOutlet private var subjectLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    
    // MARK: - Rx
    
    private var disposeBag: DisposeBag!
    
    // MARK: - Injected
    
    var presenter: SendFeeCellPresenter! {
        didSet {
            guard let presenter = presenter else { return }
            presenter.fee
                .drive(valueLabel.rx.text)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        disposeBag = DisposeBag()
        subjectLabel.text = LocalizationConstants.Send.Fees.subject
        setupAccessibility()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        presenter = nil
    }
    
    // MARK: - Setup
    
    private func setupAccessibility() {
        contentView.accessibility = Accessibility(isAccessible: false)
        subjectLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.feesTitleLabel)
        )
        valueLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.feesValueLabel)
        )
    }
}
