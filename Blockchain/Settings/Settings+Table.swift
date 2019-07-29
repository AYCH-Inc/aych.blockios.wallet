//
//  Settings+Table.swift
//  Blockchain
//
//  Created by Justin on 7/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import PlatformUIKit
import SafariServices

extension SettingsTableViewController {

    enum SettingsCell {
        case base, identity, wallet, pit, email, phoneNumber, currency, recovery, emailNotifications, twoFA, biometry, swipeReceive
    }

    func reloadTableView() {
        tableView.reloadData()
    }

    func prepareBaseCell(_ cell: UITableViewCell) {
        cell.textLabel?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Medium)
        cell.detailTextLabel?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Small)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func preparePITLinkingCell(_ cell: UITableViewCell) {
        getPITLinkingStatus { [weak self] linked in
            guard let self = self else { return }
            cell.textLabel?.text = LocalizationConstants.PIT.title
            cell.detailTextLabel?.text = linked ? LocalizationConstants.PIT.connected.uppercased() : LocalizationConstants.PIT.connect.uppercased()
            self.createBadge(cell, color: .brandSecondary)
        }
    }

    func prepareBiometryCell(_ cell: UITableViewCell) {
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.selectionStyle = .none
        cell.textLabel?.text = biometryTypeDescription()
        let biometrySwitch = UISwitch()
        let biometryEnabled = BlockchainSettings.sharedAppInstance().biometryEnabled
        biometrySwitch.isOn = biometryEnabled
        biometrySwitch.addTarget(self, action: #selector(self.biometrySwitchTapped), for: .touchUpInside)
        cell.accessoryView = biometrySwitch
        cell.updateConstraintsIfNeeded()
    }

    func prepareWalletCell(_ cell: UITableViewCell) {
        cell.detailTextLabel?.textColor = .brandPrimary
        cell.detailTextLabel?.text = "Copy".localized()
    }

    func prepareEmailCell(_ cell: UITableViewCell) {
        getUserEmail() != nil &&
            WalletManager.shared.wallet.getEmailVerifiedStatus() == true ? formatDetailCell(true, cell) : formatDetailCell(false, cell)
    }

    func preparePhoneNumberCell(_ cell: UITableViewCell) {
         WalletManager.shared.wallet.hasVerifiedMobileNumber() ? formatDetailCell(true, cell) : formatDetailCell(false, cell)
    }

    func prepareCurrencyCell(_ cell: UITableViewCell) {
        let selectedCurrencyCode = getLocalSymbolFromLatestResponse()?.code
        let selectedCurrencySymbol = getLocalSymbolFromLatestResponse()?.symbol
        cell.textLabel?.text = LocalizationConstants.localCurrency
        cell.detailTextLabel?.textColor = .brandPrimary
        if let selectedCode = selectedCurrencyCode {
            if self.allCurrencySymbolsDictionary[selectedCode] == nil {
                updateAccountInfo()
            }
        }

        if selectedCurrencySymbol == nil {
            cell.detailTextLabel?.text = ""
        }

        if let currencyCode = selectedCurrencyCode,
            let fiatRepresentable = allCurrencySymbolsDictionary[currencyCode] as? [String: Any] {
            let parsedFiat = FiatCurrency(dictionary: fiatRepresentable)
            cell.detailTextLabel?.text = parsedFiat.description
        }
    }

    func prepareSwipeReceiveCell(_ cell: UITableViewCell) {
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        let switchForSwipeToReceive = UISwitch()
        let swipeToReceiveEnabled: Bool = BlockchainSettings.sharedAppInstance().swipeToReceiveEnabled
        switchForSwipeToReceive.isOn = swipeToReceiveEnabled
        switchForSwipeToReceive.addTarget(self, action: #selector(self.switchSwipeToReceiveTapped), for: .touchUpInside)
        cell.accessoryView = switchForSwipeToReceive
    }

    func prepare2FACell(_ cell: UITableViewCell) {
        let authType = WalletManager.shared.wallet.getTwoStepType()
        cell.detailTextLabel?.textColor = .white
        createBadge(cell, color: .green)
        if authType == AuthenticationTwoFactorType.sms.rawValue {
            cell.detailTextLabel?.text = "SMS".localized()
        } else if authType == AuthenticationTwoFactorType.google.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.Authentication.googleAuth
        } else if authType == AuthenticationTwoFactorType.yubiKey.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.Authentication.yubiKey
        } else if authType == AuthenticationTwoFactorType.none.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.disabled
            cell.detailTextLabel?.textColor = .white
            createBadge(cell, color: .unverified)
        } else {
            createBadge(cell, color: .unverified)
            cell.detailTextLabel?.text = LocalizationConstants.unknown
        }
    }

    func prepareRecoveryCell(_ cell: UITableViewCell) {
        if WalletManager.shared.wallet.isRecoveryPhraseVerified() {
            cell.detailTextLabel?.text = LocalizationConstants.verified
            cell.detailTextLabel?.textColor = .white
            createBadge(cell, color: .green)
        } else {
            cell.detailTextLabel?.text = LocalizationConstants.unconfirmed
            cell.detailTextLabel?.textColor = .white
            createBadge(cell, color: .unverified)
        }
    }

    func prepareEmailNotificationsCell(_ cell: UITableViewCell) {
        let switchForEmailNotifications = UISwitch()
        switchForEmailNotifications.isOn = emailNotificationsEnabled()
        switchForEmailNotifications.addTarget(self, action: #selector(self.toggleEmailNotifications), for: .touchUpInside)
        cell.accessoryView = switchForEmailNotifications
    }

    func getPITLinkingStatus(handler: @escaping (Bool) -> Void) {
        repositoryAPI.hasLinkedPITAccount
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { value in
                handler(value)
            }, onError: { error in
                handler(false)
                Logger.shared.error(error)
            })
            .disposed(by: bag)
    }
    
    func getTiersStatus(handler: @escaping (KYCUserTiersResponse?) -> Void) {
        BlockchainDataRepository.shared.tiers
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                handler(response)
            }, onError: { error in
                handler(nil)
            })
        .disposed(by: bag)
    }

    func prepareIdentityCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = LocalizationConstants.Swap.swapLimit

        guard didFetchTiers else {
            cell.detailTextLabel?.isHidden = true
            getTiersStatus { [weak self] tiers in
                guard let strongSelf = self else { return }
                strongSelf.tiers = tiers
                strongSelf.didFetchTiers = true
            }
            return
        }
        
        let showLockedLabel = {
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.font = UIFont(
                name: Constants.FontNames.montserratLight,
                size: Constants.FontSizes.Small
            )
            cell.detailTextLabel?.textColor = .brandPrimary
            cell.detailTextLabel?.text = LocalizationConstants.Swap.locked
        }
        
        guard let tiers = tiers else { showLockedLabel(); return }
        guard let badgeModel = KYCUserTiersBadgeModel(response: tiers) else {
            showLockedLabel()
            return
        }
        createBadge(cell, color: badgeModel.color, detailText: badgeModel.text)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func prepareRow(_ cell: UITableViewCell, _ format: SettingsCell) {
        switch format {
        case .identity: prepareIdentityCell(cell)
        case .base: prepareBaseCell(cell)
        case .pit: preparePITLinkingCell(cell)
        case .biometry: prepareBiometryCell(cell)
        case .wallet: prepareWalletCell(cell)
        case .email: prepareEmailCell(cell)
        case .phoneNumber: preparePhoneNumberCell(cell)
        case .currency: prepareCurrencyCell(cell)
        case .swipeReceive: prepareSwipeReceiveCell(cell)
        case .twoFA: prepare2FACell(cell)
        case .recovery: prepareRecoveryCell(cell)
        case .emailNotifications: prepareEmailNotificationsCell(cell)
        }
    }

    // MARK: - UITableViewDelegate

    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        prepareRow(cell, .base)
        switch (indexPath.section, indexPath.row) {
        case (sections.profile, identityVerification): self.prepareRow(cell, .identity)
        case (sections.profile, profileWalletIdentifier): prepareRow(cell, .wallet)
        case (sections.profile, profileEmail): prepareRow(cell, .email)
        case (sections.profile, profileMobileNumber): prepareRow(cell, .phoneNumber)
        case (sections.preferences, preferencesEmailNotifications): prepareRow(cell, .emailNotifications)
        case (sections.preferences, preferencesLocalCurrency): prepareRow(cell, .currency)
        case (sections.security, securityTwoStep): prepareRow(cell, .twoFA)
        case (sections.security, securityWalletRecoveryPhrase): prepareRow(cell, .recovery)
        case (sections.security, pinBiometry): prepareRow(cell, .biometry)
        case (sections.security, pinSwipeToReceive): prepareRow(cell, .swipeReceive)
        case (sections.pit, pitIndex): prepareRow(cell, .pit)
        default: break
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case sections.pit where !sections.includesPitLinking:
            return UIView()
        default:
            let sectionHeaderView = SettingsTableSectionHeader.fromNib() as SettingsTableSectionHeader
            sectionHeaderView.label.text = self.tableView(self.tableView, titleForHeaderInSection: section)
            return sectionHeaderView
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case sections.pit where !sections.includesPitLinking:
            return 1 // Because 0 is disregarded
        default:
            return 50
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == sections.profile && indexPath.row == profileWalletIdentifier {
            return indexPath
        }
        let hasLoadedAccountInfoDictionary = walletManager.wallet.hasLoadedAccountInfo ? true : false
        if !hasLoadedAccountInfoDictionary || (UserDefaults.standard.object(forKey: "loadedSettings") as! Int != 0) == false {
            alertUserOfErrorLoadingSettings()
            return nil
        } else {
            return indexPath
        }
    }
    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case sections.profile:
            switch indexPath.row {
            case identityVerification:
                swapTapped()
            case profileWalletIdentifier:
                walletIdentifierClicked()
            case profileEmail:
                emailClicked()
            case profileMobileNumber:
                mobileNumberClicked()
            case profileWebLogin:
                webLoginClicked()
            default:
                return
            }
        case sections.pit:
            switch indexPath.row {
            case pitIndex:
                guard let supportURL = URL(string: Constants.Url.pitSupport) else { return }
                let startPITCoordinator = { [weak self] in
                    guard let self = self else { return }
                    PitCoordinator.shared.start(from: self)
                }
                let launchPIT = AlertAction(
                    style: .confirm(LocalizationConstants.PIT.Launch.launchPIT),
                    metadata: .block(startPITCoordinator)
                )
                let contactSupport = AlertAction(
                    style: .default(LocalizationConstants.PIT.Launch.contactSupport),
                    metadata: .url(supportURL)
                )
                let model = AlertModel(
                    headline: LocalizationConstants.PIT.title,
                    body: nil,
                    actions: [launchPIT, contactSupport],
                    image: #imageLiteral(resourceName: "pit-icon"),
                    dismissable: true,
                    style: .sheet
                )
                let alert = AlertView.make(with: model) { [weak self] action in
                    guard let self = self else { return }
                    guard let metadata = action.metadata else { return }
                    switch metadata {
                    case .block(let block):
                        block()
                    case .url(let support):
                        let controller = SFSafariViewController(url: support)
                        controller.modalPresentationStyle = .overFullScreen
                        self.present(controller, animated: true, completion: nil)
                    case .dismiss,
                         .pop,
                         .payload:
                        break
                    }
                }
                alert.show()
            default:
                return
            }
        case sections.preferences:
            switch indexPath.row {
            case preferencesLocalCurrency:
                performSingleSegue(withIdentifier: "currency", sender: nil)
            default:
                return
            }
        case sections.security:
            if indexPath.row == securityTwoStep {
                showTwoStep()
            } else if indexPath.row == securityPasswordChange {
                changePassword()
            } else if indexPath.row == securityWalletRecoveryPhrase {
                showBackup()
            } else if indexPath.row == PINChangePIN {
                AuthenticationCoordinator.shared.changePin()
            }
        case sections.about:
            switch indexPath.row {
            case aboutUs:
                aboutUsClicked()
            case aboutTermsOfService:
                termsOfServiceClicked()
            case aboutPrivacyPolicy:
                showPrivacyPolicy()
            case aboutCookiePolicy:
                showCookiePolicy()
            default:
                return
            }
        default: return
        }
    }
}

class EdgeInsetBadge: EdgeInsetLabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

class EdgeInsetLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

extension EdgeInsetLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }

    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }

    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }

    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}
