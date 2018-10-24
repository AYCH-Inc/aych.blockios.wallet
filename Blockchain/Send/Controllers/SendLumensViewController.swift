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
    func onXLMEntry(_ value: String)
    func onFiatEntry(_ value: String)
    func onPrimaryTapped()
    func onUseMaxTapped()
}

@objc class SendLumensViewController: UIViewController, BottomButtonContainerView {
    
    // MARK: BottomButtonContainerView
    
    var originalBottomButtonConstraint: CGFloat!
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
    
    // MARK: Private IBOutlets (UITextField)
    
    @IBOutlet fileprivate var stellarAddressField: UITextField!
    @IBOutlet fileprivate var stellarAmountField: UITextField!
    @IBOutlet fileprivate var fiatAmountField: UITextField!
    
    // MARK: Private IBOutlets (Other)
    
    @IBOutlet fileprivate var useMaxLabel: ActionableLabel!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!
    
    weak var delegate: SendXLMViewControllerDelegate?
    fileprivate var coordinator: SendXLMCoordinator!
    fileprivate var trigger: ActionableTrigger?
    
    // MARK: Factory
    
    @objc class func make() -> SendLumensViewController {
        let controller = SendLumensViewController.makeFromStoryboard()
        return controller
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
        let services = XLMServices(configuration: .test)
        let provider = XLMServiceProvider(services: services)
        coordinator = SendXLMCoordinator(serviceProvider: provider, interface: self)
        view.frame = UIView.rootViewSafeAreaFrame(
            navigationBar: true,
            tabBar: true,
            assetSelector: true
        )
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        setUpBottomButtonContainerView()
        useMaxLabel.delegate = self
        delegate?.onLoad()
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
}

extension SendLumensViewController: SendXLMInterface {
    func updateActionableLabel(trigger: ActionableTrigger) {
        self.trigger = trigger
        let primary = NSMutableAttributedString(
            string: trigger.primaryString,
            attributes: useMaxAttributes()
        )
        
        let secondary = NSAttributedString(
            string: trigger.callToAction,
            attributes: useMaxActionAttributes()
        )
        primary.append(secondary)
        useMaxLabel.attributedText = primary
    }
    
    func updateActivityIndicator(_ visibility: Visibility) {
        
    }
    
    func errorIndicator(_ visibility: Visibility) {
        
    }
    
    func errorLabelText(_ value: String) {
        
    }
    
    func continueButtonEnabled(_ value: Bool) {
        
    }
    
    func useMaxButtonEnabled(_ value: Bool) {
        
    }
    
    func useTotalPromptText(_ value: String) {
        
    }
    
    func feeLabelText(_ value: String) {
        
    }
    
    func stellarAddressText(_ value: String) {
        
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
        // TODO: Set the text field directly for now. However, this string should be parsed according to
        // the URI scheme defined in SEP-0007
        // TICKET: IOS-1518
        stellarAddressField.text = scannedString
    }
}
