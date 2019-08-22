//
//  SendAmountTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PlatformUIKit

/// The cell displays the corresponding crypto-fiat amounts as per assets
final class SendAmountTableViewCell: UITableViewCell {
    
    // MARK: - UI Properties
    
    @IBOutlet private var cryptoSubjectLabel: UILabel!
    @IBOutlet private var cryptoValueTextField: UITextField!
    @IBOutlet private var fiatSubjectLabel: UILabel!
    @IBOutlet private var fiatValueTextField: UITextField!
    @IBOutlet private var maxSpendableBalanceButton: UIButton!
    
    // MARK: - Rx
    
    private var disposeBag: DisposeBag!
    
    // MARK: - Injected
    
    var presenter: SendAmountCellPresenter! {
        didSet {
            guard let presenter = presenter else { return }
            
            cryptoSubjectLabel.text = presenter.cryptoName
            cryptoValueTextField.placeholder = presenter.cryptoPlaceholder
            
            presenter.fiatName
                .drive(fiatSubjectLabel.rx.text)
                .disposed(by: disposeBag)
            fiatValueTextField.placeholder = presenter.fiatPlaceholder
            
            spendableBalancePresenter.attributedString
                .drive(maxSpendableBalanceButton.rx.attributedTitle(for: .normal))
                .disposed(by: disposeBag)

            maxSpendableBalanceButton.rx.tap
                .bind(to: spendableBalancePresenter.tapRelay)
                .disposed(by: disposeBag)
            
            // Upon tapping max spendable balance - fill fiat field
            spendableBalancePresenter.spendableBalanceTap
                .map { $0.fiat }
                .map { $0.toDisplayString(includeSymbol: false) }
                .bind { [weak self] text in
                    self?.presenter.fiatFieldEdited(rawValue: text)
                }
                .disposed(by: disposeBag)
            
            // Upon tapping max spendable balance - fill crypto field
            spendableBalancePresenter.spendableBalanceTap
                .map { $0.crypto }
                .map { $0.toDisplayString(includeSymbol: false) }
                .bind { [weak self] text in
                    self?.presenter.cryptoFieldEdited(rawValue: text)
                }
                .disposed(by: disposeBag)
            
            presenter.cryptoValue
                .drive(cryptoValueTextField.rx.text)
                .disposed(by: disposeBag)
            
            presenter.fiatValue
                .drive(fiatValueTextField.rx.text)
                .disposed(by: disposeBag)
        }
    }
    
    /// Accessible only when `presenter` references a value
    private var spendableBalancePresenter: SendSpendableBalanceViewPresenter {
        return presenter.spendableBalancePresenter
    }
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        disposeBag = DisposeBag()
        setupAccessibility()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
        disposeBag = DisposeBag()
    }
    
    // MARK: - Setup
    
    func prepare(using inputAccessoryView: UIView) {
        cryptoValueTextField.inputAccessoryView = inputAccessoryView
        fiatValueTextField.inputAccessoryView = inputAccessoryView
    }
    
    private func setupAccessibility() {
        contentView.accessibility = Accessibility(isAccessible: false)
        cryptoSubjectLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.cryptoTitleLabel)
        )
        cryptoValueTextField.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.cryptoAmountTextField)
        )
        fiatSubjectLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.fiatTitleLabel)
        )
        fiatValueTextField.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.fiatAmountTextField)
        )
        maxSpendableBalanceButton.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.maxAvailableLabel)
        )
    }
}

// MARK: - UITextFieldDelegate

extension SendAmountTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let input = (text as NSString).replacingCharacters(in: range, with: string)
        if textField == fiatValueTextField {
            presenter.fiatFieldEdited(rawValue: input)
        } else if textField == cryptoValueTextField {
            presenter.cryptoFieldEdited(rawValue: input)
        }
        return true
    }
}
