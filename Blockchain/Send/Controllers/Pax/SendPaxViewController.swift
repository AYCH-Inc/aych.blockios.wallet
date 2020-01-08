//
//  SendPaxViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import SafariServices
import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit
import EthereumKit
import ERC20Kit

protocol SendPaxViewControllerDelegate: class {
    func onLoad()
    func onAppear()
    func onConfirmSendTapped()
    func onSendProposed()
    func onPaxEntry(_ value: CryptoValue?)
    func onFiatEntry(_ value: FiatValue)
    func onAddressEntry(_ value: String?)
    func onErrorBarButtonItemTapped()
    func onExchangeAddressButtonTapped()
    func onQRBarButtonItemTapped()
    
    var rightNavigationCTAType: NavigationCTAType { get }
}

class SendPaxViewController: UIViewController {
    
    // MARK: Public Properties
    
    weak var delegate: SendPaxViewControllerDelegate?
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var outerStackView: UIStackView!
    @IBOutlet private var topGravityStackView: UIStackView!

    @IBOutlet private var sourceAccountTitleLabel: UILabel!
    @IBOutlet private var sourceAccountValueLabel: UILabel!
    
    @IBOutlet private var destinationAddressTitleLabel: UILabel!
    @IBOutlet private var destinationAddressIndicatorLabel: UILabel!
    @IBOutlet private var destinationAddressTextField: UITextField!

    @IBOutlet private var feesTitleLabel: UILabel!
    @IBOutlet private var networkFeesLabel: UILabel!
    
    @IBOutlet private var maxAvailableLabel: ActionableLabel!

    @IBOutlet private var cryptoTitleLabel: UILabel!
    @IBOutlet private var cryptoAmountTextField: UITextField!
    
    @IBOutlet private var fiatTitleLabel: UILabel!
    @IBOutlet private var fiatAmountTextField: UITextField!
    
    @IBOutlet private var sendNowButton: UIButton!
    @IBOutlet private var exchangeAddressButton: UIButton!
    
    private var fields: [UITextField] {
        return [
            destinationAddressTextField,
            cryptoAmountTextField,
            fiatAmountTextField
        ]
    }
    
    // MARK: Private Properties
        
    private var coordinator: SendPaxCoordinator!
    private let alertViewPresenter: AlertViewPresenter = AlertViewPresenter.shared
    private let loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared
    private var qrScannerViewModel: QRCodeScannerViewModel<AddressQRCodeParser>?
    private let analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared
    
    private var maxAvailableTrigger: ActionableTrigger? {
        didSet {
            guard let trigger = maxAvailableTrigger else {
                maxAvailableLabel.text = ""
                return
            }

            let maxText = NSMutableAttributedString(
                string: trigger.primaryString,
                attributes: useMaxAttributes()
            )

            let CTA = NSAttributedString(
                string: trigger.callToAction,
                attributes: useMaxActionAttributes()
            )

            maxText.append(CTA)

            maxAvailableLabel.attributedText = maxText
        }
    }
    
    // MARK: Class Functions
    
    @objc class func make() -> SendPaxViewController {
        return SendPaxViewController.makeFromStoryboard()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = SendPaxCoordinator(
            interface: self,
            exchangeAddressPresenter: SendExchangeAddressStatePresenter(assetType: .pax)
        )
        fields.forEach({ $0.delegate = self })
        topGravityStackView.addBackgroundColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        sendNowButton.layer.cornerRadius = 4.0
        sendNowButton.setTitle(LocalizationConstants.continueString, for: .normal)
        maxAvailableLabel.delegate = self
        delegate?.onLoad()
        setupKeyboard()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.onAppear()
    }
    
    private func setupAccessibility() {
        sourceAccountTitleLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.sourceAccountTitleLabel
        sourceAccountValueLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.sourceAccountValueLabel
        
        destinationAddressTitleLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.destinationAddressTitleLabel
        destinationAddressTextField.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.destinationAddressTextField
        destinationAddressIndicatorLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.destinationAddressIndicatorLabel
        
        feesTitleLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.feesTitleLabel
        networkFeesLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.feesValueLabel
        
        maxAvailableLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.maxAvailableLabel
        
        cryptoTitleLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.cryptoTitleLabel
        cryptoAmountTextField.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.cryptoAmountTextField

        fiatTitleLabel.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.fiatTitleLabel
        fiatAmountTextField.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.fiatAmountTextField
        
        exchangeAddressButton.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.exchangeAddressButton
        
        sendNowButton.accessibilityIdentifier = AccessibilityIdentifiers.SendScreen.continueButton
    }
    
    private func setupKeyboard() {
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [ flexibleSpace, doneButton ]
        bar.sizeToFit()
        
        destinationAddressTextField.inputAccessoryView = bar
        fiatAmountTextField.inputAccessoryView = bar
        cryptoAmountTextField.inputAccessoryView = bar
        hideKeyboardWhenTappedAround()
    }
    
    private func apply(_ update: SendMoniesPresentationUpdate) {
        switch update {
        case .cryptoValueTextField(let amount):
            guard cryptoAmountTextField.isFirstResponder == false else { return }
            if amount?.amount == 0 {
                cryptoAmountTextField.text = ""
            } else {
                cryptoAmountTextField.text = amount?.toDisplayString(includeSymbol: false)
            }
        case .feeValueLabel(let fee):
            networkFeesLabel.text = fee
        case .toAddressTextField(let address):
            destinationAddressTextField.text = address
        case .fiatValueTextField(let amount):
            guard fiatAmountTextField.isFirstResponder == false else { return }
            if amount?.amount == 0 {
                fiatAmountTextField.text = ""
            } else {
                fiatAmountTextField.text = amount?.toDisplayString(includeSymbol: false, locale: Locale.current)
            }
        case .loadingIndicatorVisibility(let visibility):
            switch visibility {
            case .hidden:
                loadingViewPresenter.hide()
            case .visible:
                loadingViewPresenter.show(with: LocalizationConstants.loading)
            }
        case .sendButtonEnabled(let enabled):
            sendNowButton.isEnabled = enabled
            sendNowButton.alpha = enabled ? 1.0 : 0.5
        case .textFieldEditingEnabled(let editable):
            fields.forEach({ $0.isEnabled = editable })
        case .showAlertSheetForError(let error):
            handle(error: error)
        case .showAlertSheetForSuccess:
            let alert = AlertModel(
                headline: LocalizationConstants.success,
                body: LocalizationConstants.SendAsset.paymentSent,
                image: #imageLiteral(resourceName: "eth_good"),
                style: .sheet
            )
            let alertView = AlertView.make(with: alert, completion: nil)
            alertView.show()
        case .hideConfirmationModal:
            ModalPresenter.shared.closeAllModals()
        case .updateNavigationItems:
            if let navController = navigationController as? BaseNavigationController {
                navController.update()
            }
        case .walletLabel(let accountLabel):
            sourceAccountValueLabel.text = accountLabel
        case .maxAvailable(let max):
            maxAvailableTrigger = ActionableTrigger(
                text: LocalizationConstants.SendAsset.useTotalSpendableBalance,
                CTA: max?.toDisplayString(includeSymbol: true) ?? "..."
            ) { [weak self] in
                guard let max = max else { return }
                self?.delegate?.onPaxEntry(max)
            }
        case .fiatCurrencyLabel(let fiatCurrency):
            fiatTitleLabel.text = fiatCurrency
        case .exchangeAddressButtonVisibility(let isVisible):
            exchangeAddressButton.isHidden = !isVisible
        case .useExchangeAddress(let address):
            destinationAddressTextField.text = address
            if address == nil {
                exchangeAddressButton.setImage(UIImage(named: "exchange-icon-small"), for: .normal)
                destinationAddressTextField.isHidden = false
                destinationAddressIndicatorLabel.text = nil
            } else {
                exchangeAddressButton.setImage(UIImage(named: "cancel_icon"), for: .normal)
                destinationAddressTextField.isHidden = true
                destinationAddressIndicatorLabel.text = String(format: LocalizationConstants.Exchange.Send.destination,
                                                               AssetType.pax.symbol)
            }
        case .showAlertForEnabling2FA:
            alertViewPresenter.standardNotify(
                message: LocalizationConstants.Exchange.twoFactorNotEnabled,
                title: LocalizationConstants.Errors.error
            )
        }
    }
    
    // MARK: Private Helpers

    private func useMaxAttributes() -> [NSAttributedString.Key: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ]
    }

    private func useMaxActionAttributes() -> [NSAttributedString.Key: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [
            .font: font,
            .foregroundColor: UIColor.brandSecondary
        ]
    }
    
    fileprivate func handle(error: SendMoniesInternalError) {
        fields.forEach({ $0.resignFirstResponder() })
        var alert = AlertModel(
            headline: error.title,
            body: error.description,
            image: #imageLiteral(resourceName: "eth_bad"),
            style: .sheet
        )
        if error == .insufficientFeeCoverage {
            guard let url = URL(string: Constants.Url.ethGasExplanationForPax) else { return }
            let action = AlertAction(style: .confirm(LocalizationConstants.learnMore), metadata: .url(url))
            alert.actions = [action]
        }
        let alertView = AlertView.make(with: alert) { [weak self] action in
            guard let self = self else { return }
            guard let metadata = action.metadata else { return }
            switch metadata {
            case .url(let url):
                let viewController = SFSafariViewController(url: url)
                viewController.modalPresentationStyle = .overFullScreen
                self.present(viewController, animated: true, completion: nil)
            case .block,
                 .pop,
                 .payload,
                 .dismiss:
                break
            }
        }
        alertView.show()
    }
    
    // MARK: Actions
    
    @IBAction private func sendNowTapped(_ sender: UIButton) {
        delegate?.onSendProposed()
    }
    
    @IBAction private func exchangeAddressButtonPressed() {
        delegate?.onExchangeAddressButtonTapped()
    }
}

extension SendPaxViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else { return }
        if textField == cryptoAmountTextField {
            let value = CryptoValue.paxFromMajor(string: text)
            delegate?.onPaxEntry(value)
        }
        if textField == fiatAmountTextField {
            let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
            let value = FiatValue.create(amountString: text, currencyCode: currencyCode)
            delegate?.onFiatEntry(value)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == destinationAddressTextField {
            delegate?.onAddressEntry("")
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let replacementInput = (text as NSString).replacingCharacters(in: range, with: string)
        
        if textField == destinationAddressTextField {
            delegate?.onAddressEntry(replacementInput)
        }
        if textField == cryptoAmountTextField {
            let value = CryptoValue.paxFromMajor(string: replacementInput)
            delegate?.onPaxEntry(value)
        }
        if textField == fiatAmountTextField {
            let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
            let value = FiatValue.create(amountString: replacementInput, currencyCode: currencyCode)
            delegate?.onFiatEntry(value)
        }
        return true
    }
}

extension SendPaxViewController: NavigatableView {
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        if let type = delegate?.rightNavigationCTAType, type == .error {
            delegate?.onErrorBarButtonItemTapped()
        } else if let type = delegate?.rightNavigationCTAType, type == .qrCode {
            delegate?.onQRBarButtonItemTapped()
        } else if let parent = parent as? AssetSelectorContainerViewController {
            parent.navControllerRightBarButtonTapped(navController)
        }
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        if let parent = parent as? AssetSelectorContainerViewController {
            parent.navControllerLeftBarButtonTapped(navController)
        }
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return delegate?.rightNavigationCTAType ?? .qrCode
    }
    
    var rightCTATintColor: UIColor {
        guard let delegate = delegate else { return .white }
        if delegate.rightNavigationCTAType == .qrCode ||
            delegate.rightNavigationCTAType == .activityIndicator {
            return .white
        }
        return .pending
    }
}

extension SendPaxViewController: SendPAXInterface {
    func apply(updates: Set<SendMoniesPresentationUpdate>) {
        updates.forEach({ self.apply($0) })
    }
    
    func display(confirmation: BCConfirmPaymentViewModel) {
        let confirmView = BCConfirmPaymentView(
            frame: view.frame,
            viewModel: confirmation,
            sendButtonFrame: sendNowButton.frame
        )!
        confirmView.confirmDelegate = self
        ModalPresenter.shared.showModal(
            withContent: confirmView,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.SendAsset.confirmPayment
        )
    }
    
    func displayQRCodeScanner() {
        scanQrCodeForDestinationAddress()
    }
}

extension SendPaxViewController: ConfirmPaymentViewDelegate {
    func confirmButtonDidTap(_ note: String?) {
        delegate?.onConfirmSendTapped()
    }
    
    func feeInformationButtonClicked() {
        // TODO
    }
}

extension SendPaxViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SendPaxViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// TODO: Clean this up, move to Coordinator
extension SendPaxViewController {
    @objc func scanQrCodeForDestinationAddress() {
        guard let scanner = QRCodeScanner() else { return }
        
        let parser = AddressQRCodeParser(assetType: .pax)
        let textViewModel = AddressQRCodeTextViewModel()
        
        qrScannerViewModel = QRCodeScannerViewModel(
            parser: parser,
            additionalParsingOptions: .lax(routes: [.exchangeLinking]),
            textViewModel: textViewModel,
            scanner: scanner,
            completed: { [weak self] result in
                self?.handleAddressScan(result: result)
            }
        )
        
        let viewController = QRCodeScannerViewControllerBuilder(viewModel: qrScannerViewModel)?
            .with(presentationType: .modal(dismissWithAnimation: false))
            .build()
        
        guard let qrCodeScannerViewController = viewController else { return }
        
        DispatchQueue.main.async {
            guard let controller = AppCoordinator.shared.tabControllerManager.tabViewController else { return }
            controller.present(qrCodeScannerViewController, animated: true, completion: nil)
        }
    }
    
    private func handleAddressScan(result: Result<AddressQRCodeParser.Address, AddressQRCodeParser.AddressQRCodeParserError>) {
        if case .success(let assetURL) = result {
            let address = assetURL.payload.address
            delegate?.onAddressEntry(address)
            destinationAddressTextField.text = address

            guard
                let amount = assetURL.payload.amount,
                let value = CryptoValue.paxFromMajor(string: amount)
            else {
                return
            }
            delegate?.onPaxEntry(value)
            cryptoAmountTextField.insertText(amount)
        }
    }
}

extension SendPaxViewController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        return maxAvailableTrigger?.actionRange()
    }

    func actionRequestingExecution(label: ActionableLabel) {
        guard let trigger = maxAvailableTrigger else { return }
        analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormUseBalanceClick(asset: .pax))
        trigger.execute()
    }
}
