//
//  PitConnectViewController.swift
//  Blockchain
//
//  Created by AlexM on 7/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

class PitConnectViewController: UIViewController, NavigatableView {
    
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
    
    @IBOutlet private var pitDescriptionLabel: UILabel!
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
        title = LocalizationConstants.PIT.title
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
        pitDescriptionLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.description
        lightningTradesLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.lightningFast
        accessCryptosLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.accessCryptos
        builtByBlockchainLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.builtByBlockchain
        withdrawDollarsLabel.text = LocalizationConstants.PIT.ConnectionPage.Descriptors.withdrawDollars
        
        ableToLabel.text = LocalizationConstants.PIT.ConnectionPage.Features.pitWillBeAbleTo
        notAbleToLabel.text = LocalizationConstants.PIT.ConnectionPage.Features.pitWillNotBeAbleTo
        
        shareYourStatus.attributedText = NSAttributedString(
            string: LocalizationConstants.PIT.ConnectionPage.Features.shareStatus,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        exchangeAddresses.attributedText = NSAttributedString(
            string: LocalizationConstants.PIT.ConnectionPage.Features.shareAddresses,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        viewWalletPassword.attributedText = NSAttributedString(
            string: LocalizationConstants.PIT.ConnectionPage.Features.viewYourPassword,
            attributes: [.font: copyFont()
            ]
        ).asBulletPoint()
        
        learnMoreButton.setTitle(LocalizationConstants.PIT.ConnectionPage.Actions.learnMore, for: .normal)
        connectNowButton.setTitle(LocalizationConstants.PIT.ConnectionPage.Actions.connectNow, for: .normal)
        
        connectNowButton.rx.tap
            .subscribe(onNext: { _ in
                self.connectRelay.accept(())
                self.analyticsRecorder.record(event: AnalyticsEvents.PIT.ConnectNowTapped())
            })
            .disposed(by: bag)
        
        learnMoreButton.rx.tap
            .subscribe(onNext: { _ in
                self.learnMoreRelay.accept(())
                self.analyticsRecorder.record(event: AnalyticsEvents.PIT.LearnMoreTapped())
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

extension PitConnectViewController {
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        PitCoordinator.shared.stop()
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
