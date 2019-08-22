//
//  SendSourceAccountTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PlatformUIKit

/// The source account table view cell on the send screen.
final class SendSourceAccountTableViewCell: UITableViewCell {

    // MARK: - UI Properties
    
    @IBOutlet private var subjectLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!

    // MARK: - Rx
    
    private var disposable: Disposable!
    
    // MARK: - Injected

    var presenter: SendSourceAccountCellPresenter! {
        didSet {
            guard let presenter = presenter else { return }
            disposable = presenter.account.drive(valueLabel.rx.text)
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        subjectLabel.text = LocalizationConstants.Send.Source.subject
        setupAccessibility()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
        disposable.dispose()
    }
    
    deinit {
        disposable.dispose()
    }
    
    // MARK: - Setup
    
    private func setupAccessibility() {
        contentView.accessibility = Accessibility(isAccessible: false)
        subjectLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.sourceAccountTitleLabel)
        )
        valueLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.sourceAccountValueLabel)
        )
    }
}

