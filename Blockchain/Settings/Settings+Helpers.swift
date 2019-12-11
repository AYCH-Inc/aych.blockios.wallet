//
//  Settings+Helpers.swift
//  Blockchain
//
//  Created by Justin on 7/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

extension SettingsTableViewController {

    func getAllCurrencySymbols() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didGetCurrencySymbols),
                                               name: NSNotification.Name(rawValue: "GetAllCurrencySymbols"), object: nil)
        WalletManager.shared.wallet.getBtcExchangeRates()
    }

    @objc func didGetCurrencySymbols() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GetAllCurrencySymbols"), object: nil)
        updateCurrencySymbols()
    }

    func getLocalSymbolFromLatestResponse() -> CurrencySymbol? {
        return WalletManager.shared.latestMultiAddressResponse?.symbol_local
    }
    func alertUserOfErrorLoadingSettings() {
        let actions = [
           UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil)
        ]
        let title = "\(LocalizationConstants.Errors.error) \(LocalizationConstants.Errors.loadingSettings)"
        let message = LocalizationConstants.Errors.checkConnection

        AlertViewPresenter.shared.standardNotify(
            message: message,
            title: title,
            actions: actions
        )
        UserDefaults.standard.set(0, forKey: "loadedSettings")
    }
    func alertUserOfSuccess(_ successMessage: String?) {
        let actions = [
            UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil)
        ]
        AlertViewPresenter.shared.standardNotify(
            message: successMessage ?? "",
            title: LocalizationConstantsObjcBridge.success(),
            actions: actions
        )
        reload()
    }

    func alertUserOfError(_ errorMessage: String) {
        AlertViewPresenter.shared.standardError(message: errorMessage)
    }

    func walletIdentifierClicked() {
        analyticsRecorder.record(event: AnalyticsEvents.Settings.settingsWalletIdCopyClick)
        let alert = UIAlertController(title: LocalizationConstants.AddressAndKeyImport.copyWalletId,
                                      message: LocalizationConstants.AddressAndKeyImport.copyWarning,
                                      preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(
            title: LocalizationConstants.AddressAndKeyImport.copyCTA,
            style: .destructive,
            handler: { [weak self] _ in
                self?.analyticsRecorder.record(event: AnalyticsEvents.Settings.settingsWalletIdCopied)
                UIPasteboard.general.string = WalletManager.shared.legacyRepository.legacyGuid
            }
        )
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(copyAction)
        present(alert, animated: true)
    }

    func emailClicked() {
        analyticsRecorder.record(event: AnalyticsEvents.Settings.settingsEmailClicked)
        let verifyEmailController = BCVerifyEmailViewController(emailDelegate: delegate)
        navigationController?.pushViewController(verifyEmailController!, animated: true)
    }

    // MARK: - Email Delegate
    func isEmailVerified() -> Bool {
        return WalletManager.shared.wallet.hasVerifiedEmail()
    }

    func getEmail() -> String? {
        return WalletManager.shared.wallet.getEmail()
    }

    func prepareForForChangingTwoStep() {
        let enableTwoStepCell: UITableViewCell? = tableView.cellForRow(at: IndexPath(row: securityTwoStep, section: sections.security))
        enableTwoStepCell?.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.changeTwoStepSuccess),
                                               name: NSNotification.Name(rawValue: "ChangeTwoStep"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.changeTwoStepError), name:
            NSNotification.Name(rawValue: "ChangeTwoStepError"),
                                               object: nil)
    }
    func doneChangingTwoStep() {
        let enableTwoStepCell: UITableViewCell? = tableView.cellForRow(at: IndexPath(row: securityTwoStep, section: sections.security))
        enableTwoStepCell?.isUserInteractionEnabled = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ChangeTwoStep"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ChangeTwoStepError"), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberDelegate = self
        self.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(SettingsToggleTableViewCell.self, forCellReuseIdentifier: "settingsToggle")
        self.tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "settingsCell")
        UserDefaults.standard.set(1, forKey: "loadedSettings")
        updateEmailAndMobileStrings()
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name:
            NSNotification.Name(rawValue: "reloadSettings"), object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadAfterMultiAddressResponse),
                                               name: NSNotification.Name(rawValue: "reloadSettingsAfterMultiAddress"),
                                               object: nil)
        
        NotificationCenter.when(Constants.NotificationKeys.kycStopped) { [weak self] _ in
            guard let this = self else { return }
            this.reloadTableView()
        }
    }
}

extension AppSettingsController {
    /// MARK: -getUserEmail
    func getUserEmail() -> String? {
        return WalletManager.shared.wallet.getEmail()
    }

    /// MARK: -formatDetailCell
    func formatDetailCell(_ verified: Bool, _ cell: UITableViewCell) {
        if verified {
            cell.detailTextLabel?.text = LocalizationConstants.verified
            self.createBadge(cell, color: .green)
        } else {
            cell.detailTextLabel?.text = LocalizationConstants.unverified
            createBadge(cell, color: .unverified)
        }
    }

    func createBadge(_ cell: UITableViewCell, color: UIColor? = nil, detailText: String? = nil) {
        guard cell.detailTextLabel?.text != detailText else { return }
        cell.detailTextLabel?.isHidden = false
        cell.detailTextLabel?.layer.cornerRadius = 4
        cell.detailTextLabel?.layer.masksToBounds = true
        if let theColor = color {
            cell.detailTextLabel?.backgroundColor = theColor
        } else {
            cell.detailTextLabel?.backgroundColor = .unverified
        }
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.font = UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.Tiny)
        if let detailTextLabelText = detailText {
            cell.detailTextLabel?.text = detailTextLabelText
        }
        cell.detailTextLabel?.sizeToFit()
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }

    /// MARK: -isMobileVerified
    func isMobileVerified() -> Bool {
        return WalletManager.shared.wallet.hasVerifiedMobileNumber()
    }

    /// MARK: -getMobileNumber
    func getMobileNumber() -> String? {
        return WalletManager.shared.wallet.getSMSNumber()
    }
}

extension CustomSettingCell {
    func styleCell() {
        title?.textColor = .brandPrimary
        title?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.MediumLarge)
    }
}

extension CustomDetailCell {
    func formatDetails() {
        subtitle?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Small)
    }

    func mockCell() {
        // Only for Interface Builder
        subtitle?.text = LocalizationConstants.more
        subtitle?.textColor = .error
    }
}
