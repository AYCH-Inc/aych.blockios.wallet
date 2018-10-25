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
    @IBOutlet fileprivate var learnAbountStellarButton: UIButton!
    
    weak var delegate: SendXLMViewControllerDelegate?
    fileprivate var coordinator: SendXLMCoordinator!
    fileprivate var trigger: ActionableTrigger?
    
    // MARK: Factory
    
    @objc class func make() -> SendLumensViewController {
        let controller = SendLumensViewController.makeFromStoryboard()
        return controller
    }
    
    // MARK: ViewUpdate
    
    enum PresentationUpdate {
        case activityIndicatorVisibility(Visibility)
        case errorLabelVisibility(Visibility)
        case learnAboutStellarButtonVisibility(Visibility)
        case actionableLabelVisibility(Visibility)
        case errorLabelText(String)
        case feeAmountLabelText(String)
        case stellarAddressText(String)
        case xlmFieldTextColor(UIColor)
        case fiatFieldTextColor(UIColor)
        case actionableLabelTrigger(ActionableTrigger)
        case primaryButtonEnabled(Bool)
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
    
    fileprivate func apply(_ update: PresentationUpdate) {
        switch update {
        case .activityIndicatorVisibility(let visibility):
            // TODO
            break
        case .errorLabelVisibility(let visibility):
            errorLabel.isHidden = visibility.isHidden
        case .learnAboutStellarButtonVisibility(let visibility):
            learnAbountStellarButton.isHidden = visibility.isHidden
        case .actionableLabelVisibility(let visibility):
            useMaxLabel.isHidden = visibility.isHidden
        case .errorLabelText(let value):
            errorLabel.text = value
        case .feeAmountLabelText(let value):
            feeAmountLabel.text = value
        case .stellarAddressText(let value):
            stellarAddressField.text = value
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
        }
    }
}

extension SendLumensViewController: SendXLMInterface {
    func apply(updates: [PresentationUpdate]) {
        updates.forEach({ apply($0) })
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
