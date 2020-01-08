//
//  SendDestinationAccountTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PlatformKit
import PlatformUIKit

/// Destination account cell on send screen
final class SendDestinationAccountTableViewCell: UITableViewCell {
    
    // MARK: - UI Properties
    
    @IBOutlet private var subjectLabel: UILabel!
    
    /// A label that provides a cover for the input in case the account are being chosen from a list, e.g Exchange
    @IBOutlet private var coverLabel: UILabel!
    
    /// The destination address text field
    @IBOutlet private var textField: UITextField!
    
    /// Accessory stack view that can contain various views (e.g Exchange, disclosure buttons)
    @IBOutlet private var accessoryStackView: UIStackView!
    
    /// The exchange address button that should be configured only if the exchange address is available for the asset
    private var exchangeButton: UIButton!
    
    // MARK: - Rx
    
    private var disposeBag: DisposeBag!
    private var exchangeButtonDisposeBag: DisposeBag!
    
    // MARK: - Injected
    
    var presenter: SendDestinationAccountCellPresenter! {
        didSet {
            guard presenter != nil else { return }
            setupTextField()
            setupCoverLabel()
            configureExchangeButtonIfNeeded()
        }
    }
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        disposeBag = DisposeBag()
        exchangeButtonDisposeBag = DisposeBag()
        subjectLabel.text = LocalizationConstants.Send.Destination.subject
        setupAccessibility()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
        disposeBag = DisposeBag()
        exchangeButtonDisposeBag = DisposeBag()
    }
    
    // MARK: - Setup
    
    /// Prepares the cell for display by giving it an input accessory view
    func prepare(using inputAccessoryView: UIView) {
        textField.inputAccessoryView = inputAccessoryView
    }
    
    private func setupAccessibility() {
        contentView.accessibility = Accessibility(isAccessible: false)
        subjectLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.destinationAddressTitleLabel)
        )
        coverLabel.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.destinationAddressIndicatorLabel)
        )
        textField.accessibility = Accessibility(
            id: .value(AccessibilityIdentifiers.SendScreen.destinationAddressTextField)
        )
    }
    
    private func setupTextField() {
        textField.placeholder = presenter.textFieldPlaceholder
        presenter.isTextFieldHidden
            .drive(textField.rx.isHidden)
            .disposed(by: disposeBag)
        presenter.scannedAddress
            .emit(to: textField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupCoverLabel() {
        presenter.coverText
            .drive(coverLabel.rx.text)
            .disposed(by: disposeBag)
        
        presenter.isCoverTextHidden
            .drive(coverLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func configureExchangeButtonIfNeeded() {
        presenter.isExchangeButtonVisible
            .subscribe(onNext: { [weak self] isVisible in
                guard let self = self else { return }
                if isVisible {
                    self.setupExchangeButton()
                } else {
                    self.removeExchangeButton()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupExchangeButton() {
        guard exchangeButton == nil else { return }
        exchangeButton = UIButton()
        exchangeButton.contentMode = .center
        exchangeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exchangeButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        exchangeButton.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.exchangeAddressButton
        accessoryStackView.addArrangedSubview(exchangeButton)
        
        presenter.exchangeButtonImage
            .drive(exchangeButton.rx.image(for: .normal))
            .disposed(by: exchangeButtonDisposeBag)
        
        exchangeButton.rx.tap
            .bind(to: presenter.exchangeButtonTapRelay)
            .disposed(by: exchangeButtonDisposeBag)
    }
    
    private func removeExchangeButton() {
        exchangeButton?.removeFromSuperview()
        exchangeButton = nil
        exchangeButtonDisposeBag = DisposeBag()
    }
}

// MARK: - UITextFieldDelegate

extension SendDestinationAccountTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let input = (text as NSString).replacingCharacters(in: range, with: string)
        presenter.addressFieldEdited(input: input)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        presenter.addressFieldEdited(input: "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
