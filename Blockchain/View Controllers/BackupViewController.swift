//
//  BackupViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 19-05-15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//
// swiftlint:disable line_length

import UIKit
import PlatformUIKit

@objc class BackupViewController: UIViewController, TransferAllPromptDelegate {
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var backupWalletButton: UIButton!
    @IBOutlet weak var explanation: UILabel!
    @IBOutlet weak var backupIconImageView: UIImageView!

    @objc var wallet: Wallet?
    var transferredAll = false
    private var finalHeight: CGFloat?

    private let loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        summaryLabel.font = UIFont(name: "Montserrat-SemiBold", size: Constants.FontSizes.ExtraExtraLarge)
        explanation.font = UIFont(name: "GillSans", size: Constants.FontSizes.MediumLarge)
    }

    func setUpBackupWalletButton() {
        backupWalletButton.setTitle(LocalizationConstants.Backup.backupFunds.uppercased(), for: UIControl.State())
        backupWalletButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backupWalletButton.contentHorizontalAlignment = .center
        backupWalletButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        backupWalletButton.clipsToBounds = true
        backupWalletButton.layer.cornerRadius = Constants.Measurements.BackupButtonCornerRadius
        backupWalletButton.center = CGPoint(x: view.center.x, y: backupWalletButton.center.y)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpBackupWalletButton()

        backupIconImageView.center = CGPoint(x: view.center.x, y: backupIconImageView.center.y)
        if let image = backupIconImageView.image {
            backupIconImageView.image? = image.withRenderingMode(.alwaysTemplate)
            backupIconImageView.tintColor = .error
        }

        summaryLabel.text = LocalizationConstants.ObjCStrings.BC_STRING_BACKUP_NEEDED
        summaryLabel.center = CGPoint(x: view.center.x, y: summaryLabel.center.y)
        let recoveryPhraseText = LocalizationConstants.ObjCStrings.BC_STRING_BACKUP_NEEDED_BODY_TEXT_ONE
        explanation.text = String(
            format: "%@\n\n%@", recoveryPhraseText, LocalizationConstants.ObjCStrings.BC_STRING_BACKUP_NEEDED_BODY_TEXT_TWO)
        backupWalletButton.setTitle(LocalizationConstants.ObjCStrings.BC_STRING_START_BACKUP, for: UIControl.State())

        if wallet!.isRecoveryPhraseVerified() {
            summaryLabel.text = LocalizationConstants.ObjCStrings.BC_STRING_BACKUP_COMPLETE
            explanation.text = LocalizationConstants.ObjCStrings.BC_STRING_BACKUP_COMPLETED_EXPLANATION
            backupIconImageView.image = UIImage(named: "success")?.withRenderingMode(.alwaysTemplate)
            backupIconImageView.tintColor = .green
            backupWalletButton.setTitle(LocalizationConstants.Backup.verifyBackup.uppercased(), for: UIControl.State())

            if wallet!.didUpgradeToHd() &&
                wallet!.getTotalBalanceForSpendableActiveLegacyAddresses() >= wallet!.dust() &&
                navigationController!.visibleViewController == self && !transferredAll {
                let alertToTransferAll = UIAlertController(title: LocalizationConstants.ObjCStrings.BC_STRING_TRANSFER_IMPORTED_ADDRESSES, message: LocalizationConstants.ObjCStrings.BC_STRING_TRANSFER_ALL_BACKUP, preferredStyle: .alert)
                alertToTransferAll.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil))
                alertToTransferAll.addAction(UIAlertAction(title: LocalizationConstants.ObjCStrings.BC_STRING_TRANSFER_ALL, style: .default, handler: { _ in
                    TransferAllCoordinator.shared.start(withDelegate: self)
                }))
                present(alertToTransferAll, animated: true, completion: nil)
            }
        }
        explanation.sizeToFit()
        explanation.center = CGPoint(x: view.frame.width/2, y: explanation.center.y)

        let newYPosition = (finalHeight ?? view.frame.size.height) - 40 - backupWalletButton.frame.size.height
        changeYPosition(newYPosition, viewToChange: backupWalletButton)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transferredAll = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        finalHeight = view.frame.size.height
        if wallet!.isRecoveryPhraseVerified() {
            backupWalletButton.setTitle(LocalizationConstants.Backup.verifyBackup.uppercased(), for: UIControl.State())
        } else {
            backupWalletButton.setTitle(LocalizationConstants.ObjCStrings.BC_STRING_START_BACKUP, for: UIControl.State())
        }
    }

    func changeYPosition(_ newY: CGFloat, viewToChange: UIView) {
        let posX = viewToChange.frame.origin.x
        let width = viewToChange.frame.size.width
        let height = viewToChange.frame.size.height
        viewToChange.frame = CGRect(x: posX, y: newY, width: width, height: height)
    }

    @IBAction func backupWalletButtonTapped(_ sender: UIButton) {
        if backupWalletButton.titleLabel!.text == LocalizationConstants.Backup.verifyBackup.uppercased() {
            performSegue(withIdentifier: "verifyBackup", sender: nil)
        } else {
            performSegue(withIdentifier: "backupWords", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backupWords" {
            let viewController = segue.destination as! BackupWordsViewController
            viewController.wallet = wallet
        } else if segue.identifier == "verifyBackup" {
            let viewController = segue.destination as! BackupVerifyViewController
            viewController.wallet = wallet
            viewController.isVerifying = true
        }
    }

    func didTransferAll() {
        transferredAll = true
    }

    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }

    func showSyncingView() {
        loadingViewPresenter.show(with: LocalizationConstants.syncingWallet)
    }
}
