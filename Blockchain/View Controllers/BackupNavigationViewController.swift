//
//  BackupNavigationViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 17-06-15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformUIKit

@objc class BackupNavigationViewController: UINavigationController {

    @objc var wallet: Wallet?
    var topBar: UIView!
    var closeButton: UIButton!
    
    private let loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared
    
    // TODO: Backup: Use native back button
    var isTransitioning: Bool = false {
        didSet {
            if isTransitioning == true {
                Timer.scheduledTimer(
                    timeInterval: 0.5,
                    target: self,
                    selector: #selector(BackupNavigationViewController.finishTransitioning),
                    userInfo: nil,
                    repeats: false)
            }
        }
    }
    var headerLabel: UILabel!
    var isVerifying = false

    @objc func finishTransitioning() {
        isTransitioning = false
    }

    @objc internal func reload() {
        if !isVerifying {
            self.popToRootViewController(animated: true)
            loadingViewPresenter.hide()
        }
    }

    func markIsVerifying() {
        isVerifying = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewWidth = self.view.frame.size.width
        var topPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top ?? 0
        }
        let hasTopPadding = topPadding > 0
        topBar = UIView(frame: CGRect(x: 0, y: topPadding, width: viewWidth, height: hasTopPadding ? 44 : Constants.Measurements.DefaultHeaderHeight))
        topBar.backgroundColor = .brandPrimary
        self.view.addSubview(topBar)

        setUpHeaderLabel(useSafeAreas: hasTopPadding)
        setUpCloseButton(useSafeAreas: hasTopPadding)

        let backupViewController = self.viewControllers.first as! BackupViewController
        backupViewController.wallet = self.wallet

        NotificationCenter.default.addObserver(
        self, selector: #selector(didSucceedSync),
            name: NSNotification.Name(rawValue: "backupSuccess"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFailSync),
            name: NSNotification.Name(rawValue: "syncError"),
            object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewControllers.count == 1 {
            closeButton.frame = CGRect(x: self.view.frame.size.width - 80, y: 15, width: 80, height: 51)
            closeButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 0, right: 18)
            closeButton.contentHorizontalAlignment = .right
            closeButton.center = CGPoint(x: closeButton.center.x, y: headerLabel!.center.y)
            closeButton.setImage(UIImage(named: "close"), for: UIControl.State())
        } else {
            closeButton.frame = CGRect(x: 0, y: 12, width: 85, height: 51)
            closeButton.center = CGPoint(x: closeButton.center.x, y: topBar.frame.size.height/2)
            closeButton.setTitle("", for: UIControl.State())
            closeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 0)
            closeButton.contentHorizontalAlignment = .left
            closeButton.setImage(UIImage(named: "back_chevron_icon"), for: UIControl.State())
        }
    }

    func setUpHeaderLabel(useSafeAreas: Bool) {
        headerLabel = UILabel(frame: CGRect(x: 60, y: 26, width: 200, height: 30))
        headerLabel.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.ExtraExtraLarge)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.text = LocalizationConstants.Backup.backupFunds
        headerLabel.center = CGPoint(x: topBar.frame.size.width/2, y: useSafeAreas ? topBar.frame.size.height/2 : headerLabel.center.y)
        topBar.addSubview(headerLabel!)
    }

    func setUpCloseButton(useSafeAreas: Bool) {
        closeButton = UIButton(type: UIButton.ButtonType.custom)
        closeButton.contentHorizontalAlignment = .left
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.FontSizes.Medium)
        closeButton.setTitleColor(UIColor(white: 0.56, alpha: 1.0), for: .highlighted)
        closeButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        closeButton.center = useSafeAreas ? CGPoint(x: topBar.center.x, y: topBar.frame.size.height/2) : closeButton.center
        topBar.addSubview(closeButton)
    }

    @objc func didSucceedSync() {
        self.popToRootViewController(animated: true)
        loadingViewPresenter.hide()
        isVerifying = false
    }

    @objc func didFailSync() {
        loadingViewPresenter.hide()
        isVerifying = false
    }

    @objc func backButtonClicked() {
        if !isTransitioning {
            if viewControllers.count == 1 {
                dismiss(animated: true, completion: nil)
            } else {
                popViewController(animated: true)
            }
            isTransitioning = true
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
