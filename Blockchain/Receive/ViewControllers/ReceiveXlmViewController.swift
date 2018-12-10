//
//  ReceiveXlmViewController.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import UIKit
import StellarKit
import PlatformKit
import PlatformUIKit

@objc class ReceiveXlmViewController: UIViewController {

    @IBOutlet private var labelInstructions: UILabel!
    @IBOutlet private var imageQrCode: UIImageView!
    @IBOutlet private var labelPublicKey: UILabel!
    @IBOutlet private var buttonEnterPassword: UIButton!
    @IBOutlet private var buttonRequestPayment: UIButton!

    private let wallet = WalletManager.shared.wallet
    private lazy var stellarWalletAccountRepository: StellarWalletAccountRepository = {
        return StellarWalletAccountRepository(with: wallet)
    }()
    private var disposable: Disposable?

    private var xlmAccount: StellarWalletAccount? {
        didSet {
            if let xlmAccount = xlmAccount {
                labelInstructions.text = LocalizationConstants.Receive.tapToCopyThisAddress
                imageQrCode.isHidden = false
                let payload = StellarURLPayload(address: xlmAccount.publicKey)
                let metadata = StellarQRMetadata(address: payload.absoluteString, amount: nil)
                imageQrCode.image = QRCode(metadata: metadata)?.image
                labelPublicKey.text = xlmAccount.publicKey
                buttonEnterPassword.isHidden = true
                buttonRequestPayment.isHidden = false
            } else {
                labelInstructions.text = LocalizationConstants.Stellar.secondPasswordPrompt
                imageQrCode.isHidden = true
                labelPublicKey.text = ""
                buttonEnterPassword.isHidden = false
                buttonRequestPayment.isHidden = true
            }
        }
    }

    deinit {
        disposable?.dispose()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initXlmAccountIfNeeded()
    }

    // MARK: - Actions
    @IBAction private func onEnterPasswordTapped(_ sender: UIButton) {
        initXlmAccountIfNeeded()
    }

    @IBAction private func onAddressTapped(_ sender: Any) {
        guard let xlmAccount = xlmAccount else { return }
        UIPasteboard.general.string = xlmAccount.publicKey
        labelPublicKey.animate(
            fromText: labelPublicKey.text,
            toIntermediateText: LocalizationConstants.Receive.copiedToClipboard,
            speed: 1,
            gestureReceiver: labelPublicKey
        )
    }

    @IBAction private func onRequestPaymentTapped(_ sender: UIButton) {
        Logger.shared.debug("Request payment tapped.")
        guard let xlmAccount = xlmAccount else { return }

        let message = String(format: LocalizationConstants.Stellar.pleaseSendXlmToX, xlmAccount.publicKey)
        let items: [Any] = [message, self]

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .postToFacebook]
        activityViewController.setValue(LocalizationConstants.Stellar.xlmPaymentRequest, forKey: "subject")
        self.present(activityViewController, animated: true)
    }

    // MARK: - Private

    private func initXlmAccountIfNeeded() {
        xlmAccount = nil
        disposable = stellarWalletAccountRepository.initializeMetadataMaybe()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] xlmAccount in
                self?.xlmAccount = xlmAccount
            }, onError: { error in
                Logger.shared.error("Failed to fetch XLM account.")
            })
    }

    private func initViews() {
        buttonRequestPayment.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
        buttonRequestPayment.setTitle(LocalizationConstants.Receive.requestPayment, for: .normal)

        buttonEnterPassword.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
        buttonEnterPassword.setTitle(LocalizationConstants.Stellar.enterYourSecondPassword, for: .normal)
    }
}

extension ReceiveXlmViewController {
    @objc class func newInstance() -> ReceiveXlmViewController {
        return makeFromStoryboard()
    }
}
