//
//  ExchangeConnectViewController.swift
//  Blockchain
//
//  Created by AlexM on 7/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

class ExchangeConnectViewController: UIViewController, NavigatableView {
    
    // MARK: Public (Rx)
    
    var connectRelay: PublishRelay<Void> = PublishRelay()
    var learnMoreRelay: PublishRelay<Void> = PublishRelay()
    
    // MARK: Private Properties
    
    private let bag: DisposeBag = DisposeBag()
    private let analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var shadowView: UIView!
    @IBOutlet private var outerContainerView: UIView!
    @IBOutlet private var outerStackView: UIStackView!
    @IBOutlet private var learnMoreButton: UIButton!
    @IBOutlet private var connectNowButton: UIButton!
    
    // MARK: Private IBOutlets (UILabel)
    
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var accessCryptosLabel: UILabel!
    @IBOutlet private var withdrawDollarsLabel: UILabel!
    @IBOutlet private var lightningTradesLabel: UILabel!
    @IBOutlet private var builtByBlockchainLabel: UILabel!
    @IBOutlet private var ableToLabel: UILabel!
    @IBOutlet private var notAbleToLabel: UILabel!
    
    @IBOutlet private var shareYourStatus: UILabel!
    @IBOutlet private var exchangeAddresses: UILabel!
    @IBOutlet private var viewWalletPassword: UILabel!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.Exchange.title
        outerContainerView.layer.cornerRadius = 8.0
        outerContainerView.clipsToBounds = true
        
        shadowView.layer.shadowColor = #colorLiteral(red: 0.87, green: 0.87, blue: 0.87, alpha: 1).cgColor
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowOffset = .init(width: 0, height: 2.0)
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.cornerRadius = 8.0
        
        learnMoreButton.layer.borderColor = #colorLiteral(red: 0.3, green: 0.09, blue: 0.73, alpha: 1).cgColor
        learnMoreButton.layer.borderWidth = 1.0
        learnMoreButton.layer.cornerRadius = 4.0
        
        connectNowButton.layer.cornerRadius = 4.0
        
        applyCopy()
    }
    
    private func applyCopy() {
        descriptionLabel.text = LocalizationConstants.Exchange.ConnectionPage.Descriptors.description
        lightningTradesLabel.text = LocalizationConstants.Exchange.ConnectionPage.Descriptors.lightningFast
        accessCryptosLabel.text = LocalizationConstants.Exchange.ConnectionPage.Descriptors.accessCryptos
        builtByBlockchainLabel.text = LocalizationConstants.Exchange.ConnectionPage.Descriptors.builtByBlockchain
        withdrawDollarsLabel.text = LocalizationConstants.Exchange.ConnectionPage.Descriptors.withdrawDollars
        
        ableToLabel.text = LocalizationConstants.Exchange.ConnectionPage.Features.exchangeWillBeAbleTo
        notAbleToLabel.text = LocalizationConstants.Exchange.ConnectionPage.Features.exchangeWillNotBeAbleTo
        
        shareYourStatus.attributedText = NSAttributedString(
            string: LocalizationConstants.Exchange.ConnectionPage.Features.shareStatus,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        exchangeAddresses.attributedText = NSAttributedString(
            string: LocalizationConstants.Exchange.ConnectionPage.Features.shareAddresses,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        viewWalletPassword.attributedText = NSAttributedString(
            string: LocalizationConstants.Exchange.ConnectionPage.Features.viewYourPassword,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        
        learnMoreButton.setTitle(LocalizationConstants.Exchange.ConnectionPage.Actions.learnMore, for: .normal)
        connectNowButton.setTitle(LocalizationConstants.Exchange.ConnectionPage.Actions.connectNow, for: .normal)
        
        connectNowButton.rx.tap
            .subscribe(onNext: { _ in
                self.connectRelay.accept(())
                self.analyticsRecorder.record(event: AnalyticsEvents.Exchange.exchangeConnectNowTapped)
            })
            .disposed(by: bag)
        
        learnMoreButton.rx.tap
            .subscribe(onNext: { _ in
                self.learnMoreRelay.accept(())
                self.analyticsRecorder.record(event: AnalyticsEvents.Exchange.exchangeLearnMoreTapped)
            })
            .disposed(by: bag)
    }
    
    private func copyFont() -> UIFont {
        return Font(.branded(.interMedium), size: .custom(14.0)).result
    }
    
    // MARK: Actions
    
    @IBAction private func learnMoreTapped(_ sender: UIButton) {
        // TODO:
    }
    
    @IBAction private func connectNowTapped(_ sender: UIButton) {
        // TODO:
    }
}

extension ExchangeConnectViewController {
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        ExchangeCoordinator.shared.stop()
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        // no-op
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return .dismiss
    }
    
    var leftNavControllerCTAType: NavigationCTAType {
        return .none
    }
}
