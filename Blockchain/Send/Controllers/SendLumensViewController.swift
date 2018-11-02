//
//  SendLumensViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SendXLMViewControllerDelegate: class {
    func onLoad()
    func onAppear()
    func onXLMEntry(_ value: String, latestPrice: Decimal)
    func onFiatEntry(_ value: String, latestPrice: Decimal)
    func onStellarAddressEntry()
    func onPrimaryTapped(toAddress: String, amount: Decimal, feeInXlm: Decimal, memo: String?)
    func onConfirmPayTapped(_ paymentOperation: StellarPaymentOperation)
    func onMinimumBalanceInfoTapped()
}

@objc class SendLumensViewController: UIViewController, BottomButtonContainerView {
    
    fileprivate static let topToStackView: CGFloat = 12.0
    fileprivate var keyboardHeight: CGFloat {
        let type = UIDevice.current.type
        if type.isBelow(.iPhone8Plus) {
            return 216
        } else {
            return 226
        }
    }
    
    // MARK: BottomButtonContainerView
    
    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = -50
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!
    
    // MARK: Private IBOutlets (UILabel)
    
    @IBOutlet fileprivate var fromLabel: UILabel!
    @IBOutlet fileprivate var toLabel: UILabel!
    @IBOutlet fileprivate var walletNameLabel: UILabel!
    @IBOutlet fileprivate var feeLabel: UILabel!
    @IBOutlet fileprivate var feeAmountLabel: UILabel!
    @IBOutlet fileprivate var errorLabel: UILabel!
    @IBOutlet fileprivate var stellarSymbolLabel: UILabel!
    @IBOutlet fileprivate var fiatSymbolLabel: UILabel!
    @IBOutlet fileprivate var memoLabel: UILabel!
    
    // MARK: Private IBOutlets (UITextField)
    
    @IBOutlet fileprivate var stellarAddressField: UITextField!
    @IBOutlet fileprivate var stellarAmountField: UITextField!
    @IBOutlet fileprivate var fiatAmountField: UITextField!
    @IBOutlet fileprivate var memoTextField: UITextField!
    
    fileprivate var inputFiels: [UITextField] {
        return [
            stellarAddressField,
            stellarAmountField,
            fiatAmountField,
            memoTextField
        ]
    }
    
    // MARK: Private IBOutlets (Other)
    
    @IBOutlet fileprivate var topToStackViewConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var useMaxLabel: ActionableLabel!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!
    @IBOutlet fileprivate var learnAbountStellarButton: UIButton!
    @IBOutlet fileprivate var bottomStackView: UIStackView!
    
    weak var delegate: SendXLMViewControllerDelegate?
    fileprivate var coordinator: SendXLMCoordinator!
    fileprivate var trigger: ActionableTrigger?

    // MARK: - Models
    private var pendingPaymentOperation: StellarPaymentOperation?
    private var latestPrice: Decimal? // fiat per whole unit
    private var xlmAmount: Decimal?
    private var xlmFee: Decimal?
    private var baseReserve: Decimal?

    // MARK: Factory
    
    @objc class func make(with provider: XLMServiceProvider) -> SendLumensViewController {
        let controller = SendLumensViewController.makeFromStoryboard()
        controller.coordinator = SendXLMCoordinator(
            serviceProvider: provider,
            interface: controller,
            modelInterface: controller
        )
        return controller
    }
    
    // MARK: ViewUpdate
    
    enum PresentationUpdate {
        case activityIndicatorVisibility(Visibility)
        case errorLabelVisibility(Visibility)
        case learnAboutStellarButtonVisibility(Visibility)
        case actionableLabelVisibility(Visibility)
        case errorLabelText(String)
        case feeAmountLabelText()
        case stellarAddressText(String)
        case stellarAddressTextColor(UIColor)
        case xlmFieldTextColor(UIColor)
        case fiatFieldTextColor(UIColor)
        case actionableLabelTrigger(ActionableTrigger)
        case primaryButtonEnabled(Bool)
        case showPaymentConfirmation(StellarPaymentOperation)
        case hidePaymentConfirmation
        case paymentSuccess
        case stellarAmountText(String?)
        case fiatAmountText(String?)
        case fiatSymbolLabel(String?)
    }

    // MARK: Public Methods

    @objc func scanQrCodeForDestinationAddress() {
        let qrCodeScanner = QRCodeScannerSendViewController()
        qrCodeScanner.qrCodebuttonClicked(nil)
        qrCodeScanner.delegate = self
        present(qrCodeScanner, animated: false)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = UIView.rootViewSafeAreaFrame(
            navigationBar: true,
            tabBar: true,
            assetSelector: true
        )
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        setUpBottomButtonContainerView()
        useMaxLabel.delegate = self
        memoTextField.delegate = self
        stellarAddressField.delegate = self
        primaryButtonContainer.isEnabled = true
        learnAbountStellarButton.titleLabel?.textAlignment = .center
        primaryButtonContainer.actionBlock = { [unowned self] in
            guard let toAddress = self.stellarAddressField.text else { return }
            guard let amount = self.xlmAmount else { return }
            guard let fee = self.xlmFee else { return }
            self.inputFiels.forEach({ $0.resignFirstResponder() })
            self.delegate?.onPrimaryTapped(toAddress: toAddress, amount: amount, feeInXlm: fee, memo: self.memoTextField.text)
        }
        delegate?.onLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.onAppear()
    }
    
    fileprivate func useMaxAttributes() -> [NSAttributedStringKey: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [.font: font,
                .foregroundColor: UIColor.darkGray]
    }
    
    fileprivate func useMaxActionAttributes() -> [NSAttributedStringKey: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [.font: font,
                .foregroundColor: UIColor.brandSecondary]
    }

    // swiftlint:disable function_body_length
    fileprivate func apply(_ update: PresentationUpdate) {
        switch update {
        case .activityIndicatorVisibility(let visibility):
            primaryButtonContainer.isLoading = (visibility == .visible)
        case .errorLabelVisibility(let visibility):
            errorLabel.isHidden = visibility.isHidden
        case .learnAboutStellarButtonVisibility(let visibility):
            learnAbountStellarButton.isHidden = visibility.isHidden
        case .actionableLabelVisibility(let visibility):
            useMaxLabel.isHidden = visibility.isHidden
        case .errorLabelText(let value):
            errorLabel.text = value
        case .feeAmountLabelText:
            // TODO: move formatting outside of this file
            guard let price = latestPrice, let fee = xlmFee else { return }
            let assetType: AssetType = .stellar
            let xlmSymbol = assetType.symbol
            let feeFormatted = NumberFormatter.stellarFormatter.string(from: NSDecimalNumber(decimal: fee)) ?? "\(fee)"
            let fiatCurrencySymbol = BlockchainSettings.sharedAppInstance().fiatCurrencySymbol
            let fiatAmount = price * fee
            let fiatFormatted = NumberFormatter.localCurrencyFormatter.string(from: NSDecimalNumber(decimal: fiatAmount)) ?? "\(fiatAmount)"
            let fiatText = fiatCurrencySymbol + fiatFormatted
            feeAmountLabel.text = "\(feeFormatted) \(xlmSymbol) (\(fiatText))"
        case .stellarAddressText(let value):
            stellarAddressField.text = value
        case .stellarAddressTextColor(let color):
            stellarAddressField.textColor = color
        case .xlmFieldTextColor(let color):
            stellarAmountField.textColor = color
        case .fiatFieldTextColor(let color):
            fiatAmountField.textColor = color
        case .actionableLabelTrigger(let trigger):
            self.trigger = trigger
            let primary = NSMutableAttributedString(
                string: trigger.primaryString,
                attributes: useMaxAttributes()
            )
            
            let CTA = NSAttributedString(
                string: " " + trigger.callToAction,
                attributes: useMaxActionAttributes()
            )
            
            primary.append(CTA)
            
            if let secondary = trigger.secondaryString {
                let trailing = NSMutableAttributedString(
                    string: " " + secondary,
                    attributes: useMaxAttributes()
                )
                primary.append(trailing)
            }
            
            useMaxLabel.attributedText = primary
        case .primaryButtonEnabled(let enabled):
            primaryButtonContainer.isEnabled = enabled
        case .paymentSuccess:
            showPaymentSuccess()
        case .showPaymentConfirmation(let paymentOperation):
            showPaymentConfirmation(paymentOperation: paymentOperation)
        case .hidePaymentConfirmation:
            ModalPresenter.shared.closeAllModals()
        case .stellarAmountText(let text):
            stellarAmountField.text = text
        case .fiatAmountText(let text):
            fiatAmountField.text = text
        case .fiatSymbolLabel(let text):
            fiatSymbolLabel.text = text
        }

    }

    private func showPaymentSuccess() {
        AlertViewPresenter.shared.standardNotify(
            message: LocalizationConstants.SendAsset.paymentSent,
            title: LocalizationConstants.success
        )
    }

    private func showPaymentConfirmation(paymentOperation: StellarPaymentOperation) {
        self.pendingPaymentOperation = paymentOperation
        let viewModel = BCConfirmPaymentViewModel.initialize(with: paymentOperation, price: latestPrice)
        let confirmView = BCConfirmPaymentView(
            frame: view.frame,
            viewModel: viewModel,
            sendButtonFrame: primaryButtonContainer.frame
        )!
        confirmView.confirmDelegate = self
        ModalPresenter.shared.showModal(
            withContent: confirmView,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.SendAsset.confirmPayment
        )
    }

    @IBAction private func learnAboutStellarButtonTapped(_ sender: Any) {
        delegate?.onMinimumBalanceInfoTapped()
    }
}

extension SendLumensViewController: SendXLMInterface {
    func apply(updates: [PresentationUpdate]) {
        updates.forEach({ apply($0) })
    }

    func present(viewController: UIViewController) {
        AppCoordinator.shared.tabControllerManager.tabViewController.present(viewController, animated: true)
    }
}

extension SendLumensViewController: ConfirmPaymentViewDelegate {
    func confirmButtonDidTap(_ note: String?) {
        guard let paymentOperation = pendingPaymentOperation else {
            Logger.shared.warning("No pending payment operation")
            return
        }
        delegate?.onConfirmPayTapped(paymentOperation)
    }

    func feeInformationButtonClicked() {
        // TODO
    }
}

extension SendLumensViewController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        return trigger?.actionRange()
    }
    
    func actionRequestingExecution(label: ActionableLabel) {
        guard let trigger = trigger else { return }
        trigger.execute()
    }
}

extension SendLumensViewController: QRCodeScannerViewControllerDelegate {
    func qrCodeScannerViewController(_ qrCodeScannerViewController: QRCodeScannerSendViewController, didScanString scannedString: String?) {
        qrCodeScannerViewController.dismiss(animated: false)
        guard let scanned = scannedString else { return }
        guard let payload = AssetURLPayloadFactory.create(fromString: scanned, assetType: .stellar) else {
            Logger.shared.error("Could not create payload from scanned string: \(scanned)")
            return
        }
        stellarAddressField.text = payload.address
        stellarAmountField.text = payload.amount
    }
}

extension BCConfirmPaymentViewModel {
    static func initialize(
        with paymentOperation: StellarPaymentOperation,
        price: Decimal?
    ) -> BCConfirmPaymentViewModel {
        // TODO: Refactor, move formatting out
        let assetType: AssetType = .stellar
        let xlmSymbol = assetType.symbol
        let fiatCurrencySymbol = BlockchainSettings.sharedAppInstance().fiatCurrencySymbol ?? ""

        let amountXlmDecimalNumber = NSDecimalNumber(decimal: paymentOperation.amountInXlm)
        let amountXlmString = NumberFormatter.stellarFormatter.string(from: amountXlmDecimalNumber) ?? "\(paymentOperation.amountInXlm)"
        let amountXlmStringWithSymbol = amountXlmString + " " + xlmSymbol

        let feeXlmDecimalNumber = NSDecimalNumber(decimal: paymentOperation.feeInXlm)
        let feeXlmString = NumberFormatter.stellarFormatter.string(from: feeXlmDecimalNumber) ?? "\(paymentOperation.feeInXlm)"
        let feeXlmStringWithSymbol = feeXlmString + " " + xlmSymbol

        let fiatTotalAmountText: String
        let cryptoWithFiatAmountText: String
        let amountWithFiatFeeText: String

        if let decimalPrice = price {
            let fiatAmount = NSDecimalNumber(decimal: decimalPrice).multiplying(by: NSDecimalNumber(decimal: paymentOperation.amountInXlm))
            let fiatAmountFormatted = NumberFormatter.localCurrencyFormatter.string(from: fiatAmount)
            fiatTotalAmountText = fiatAmountFormatted == nil ? "" : (fiatCurrencySymbol + fiatAmountFormatted!)
            cryptoWithFiatAmountText = fiatTotalAmountText.isEmpty ?
                amountXlmStringWithSymbol :
                "\(amountXlmStringWithSymbol) (\(fiatTotalAmountText))"

            let fiatFee = NSDecimalNumber(decimal: decimalPrice).multiplying(by: NSDecimalNumber(decimal: paymentOperation.feeInXlm))
            let fiatFeeText = NumberFormatter.localCurrencyFormatter.string(from: fiatFee) ?? ""
            amountWithFiatFeeText = fiatFeeText.isEmpty ?
                feeXlmStringWithSymbol :
                "\(feeXlmStringWithSymbol) (\(fiatCurrencySymbol)\(fiatFeeText))"
        } else {
            fiatTotalAmountText = ""
            cryptoWithFiatAmountText = amountXlmStringWithSymbol
            amountWithFiatFeeText = feeXlmStringWithSymbol
        }

        return BCConfirmPaymentViewModel(
            from: paymentOperation.sourceAccount.label ?? "",
            to: paymentOperation.destinationAccountId,
            totalAmountText: amountXlmStringWithSymbol,
            fiatTotalAmountText: fiatTotalAmountText,
            cryptoWithFiatAmountText: cryptoWithFiatAmountText,
            amountWithFiatFeeText: amountWithFiatFeeText,
            buttonTitle: LocalizationConstants.SendAsset.send,
            showDescription: paymentOperation.memo != nil,
            surgeIsOccurring: false,
            noteText: paymentOperation.memo,
            warningText: nil
        )
    }
}

extension SendLumensViewController: SendXLMModelInterface {
    func updateFee(_ value: Decimal) {
        xlmFee = value
    }

    func updatePrice(_ value: Decimal) {
        latestPrice = value
    }

    func updateXLMAmount(_ value: Decimal?) {
        xlmAmount = value
    }

    func updateBaseReserve(_ value: Decimal?) {
        baseReserve = value
    }
}

extension SendLumensViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard UIDevice.current.type == .iPhoneSE else { return }
        guard [memoTextField].contains(textField) else { return }
        let primaryButtonOffset = originalBottomButtonConstraint +
            optionalOffset +
            keyboardHeight +
            primaryButtonContainer.frame.size.height
        
        let height = view.bounds.height
        let bottomStackViewMaxY = bottomStackView.frame.maxY
        let offset = (height - bottomStackViewMaxY) - primaryButtonOffset
        
        guard topToStackViewConstraint.constant != offset else { return }
        topToStackViewConstraint.constant = offset
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard topToStackViewConstraint.constant != SendLumensViewController.topToStackView else { return }
        topToStackViewConstraint.constant = SendLumensViewController.topToStackView
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == stellarAddressField {
            return addressField(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else {
            return amountField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
    }
}

// MARK: - Text Field handling
extension SendLumensViewController {

    func amountField(_ amountField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard [fiatAmountField, stellarAmountField].contains(amountField) else { return true }
        if let text = amountField.text,
            let textRange = Range(range, in: text) {
            let newString = text.replacingCharacters(in: textRange, with: string)

            var maxDecimalPlaces: Int?
            if amountField == stellarAmountField {
                maxDecimalPlaces = NumberFormatter.stellarFractionDigits
            } else if amountField == fiatAmountField {
                maxDecimalPlaces = NumberFormatter.localCurrencyFractionDigits
            }

            guard let decimalPlaces = maxDecimalPlaces else {
                Logger.shared.error("Unhandled textfield")
                return true
            }

            let amountDelegate = AmountTextFieldDelegate(maxDecimalPlaces: decimalPlaces)
            let isInputValid = amountDelegate.textField(amountField, shouldChangeCharactersIn: range, replacementString: string)
            if !isInputValid {
                return false
            }

            guard let price = latestPrice else { return true }
            if amountField == stellarAmountField {
                delegate?.onXLMEntry(newString, latestPrice: price)
            } else if amountField == fiatAmountField {
                delegate?.onFiatEntry(newString, latestPrice: price)
            }
        }
        return true
    }

    func addressField(_ addressField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if addressField == stellarAddressField {
            delegate?.onStellarAddressEntry()
        }
        return true
    }
}
