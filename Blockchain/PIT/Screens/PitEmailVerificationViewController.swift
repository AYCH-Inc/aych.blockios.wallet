//
//  PitEmailVerificationViewController.swift
//  Blockchain
//
//  Created by AlexM on 7/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import RxCocoa
import PlatformUIKit

class PitEmailVerificationViewController: UIViewController, BottomButtonContainerView {
    
    // MARK: Public Properties (Rx)
    var verificationObserver: Observable<Void> {
        return verificationRelay.asObservable().take(1)
    }
    
    // MARK: Private Lazy Properties
    
    private lazy var presenter: VerifyEmailPresenter = {
        return VerifyEmailPresenter(view: self)
    }()
    
    private lazy var primaryFont: UIFont = {
        return Font(.branded(.montserratMedium), size: .custom(14.0)).result
    }()
    
    private lazy var primaryFontColor: UIColor = {
        return #colorLiteral(red: 0.21, green: 0.25, blue: 0.32, alpha: 1)
    }()
    
    private lazy var loadingAttributedText: NSAttributedString = {
        return NSAttributedString(
            string: LocalizationConstants.PIT.EmailVerification.justAMoment,
            attributes: [
                .font: primaryFont,
                .foregroundColor: primaryFontColor
            ])
    }()
    
    private lazy var emailSentAttributedText: NSAttributedString = {
        return NSAttributedString(
            string: LocalizationConstants.KYC.emailSent,
            attributes: [
                .font: primaryFont,
                .foregroundColor: primaryFontColor
            ])
    }()
    
    private lazy var primaryAttributes: [NSAttributedString.Key: Any] = {
        return [
            .font: primaryFont,
            .foregroundColor: primaryFontColor
        ]
    }()
    
    private lazy var secondaryAttributes: [NSAttributedString.Key: Any] = {
        return [
            .font: primaryFont,
            .foregroundColor: #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1)
        ]
    }()
    
    // MARK: Private Properties
    
    private var bag: DisposeBag = DisposeBag()
    private var verificationRelay: PublishRelay<Void> = PublishRelay()
    private var email: EmailAddress = "" {
        didSet {
            guard isViewLoaded else { return }
            emailTextField.text = email
        }
    }
    private var trigger: ActionableTrigger? {
        didSet {
            guard let trigger = trigger else { return }
            
            let primary = NSMutableAttributedString(
                string: trigger.primaryString + " ",
                attributes: primaryAttributes
            )
            let CTA = NSAttributedString(
                string: trigger.callToAction,
                attributes: secondaryAttributes
            )
            primary.append(CTA)
            resendEmailActionableLabel.attributedText = primary
        }
    }
    
    // MARK: BottomButtonContainerView
    
    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = 0
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var emailSentLabel: UILabel!
    @IBOutlet private var waitingLabel: UILabel!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var emailVerificationDescriptionLabel: UILabel!
    @IBOutlet private var resendEmailActionableLabel: ActionableLabel!
    @IBOutlet private var openMailButtonContainer: PrimaryButtonContainer!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.PIT.EmailVerification.title
        resendEmailActionableLabel.delegate = self
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        
        emailSentLabel.attributedText = emailSentAttributedText
        waitingLabel.attributedText = loadingAttributedText
        
        presenter.userEmail
            .subscribe(onSuccess: { [weak self] email in
                guard let self = self else { return }
                self.email = email.address
                self.emailTextField.text = email.address
            })
            .disposed(by: bag)
        
        trigger = ActionableTrigger(
            text: LocalizationConstants.PIT.EmailVerification.didNotGetEmail,
            CTA: LocalizationConstants.PIT.EmailVerification.sendAgain
        ) { [unowned self] in
            self.emailTextField.resignFirstResponder()
            self.presenter.sendVerificationEmail(to: self.email, contextParameter: .pitSignup)
        }
        
        presenter.sendVerificationEmail(to: email, contextParameter: .pitSignup)
        openMailButtonContainer.actionBlock = {
            UIApplication.shared.openMailApplication()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        emailTextField.becomeFirstResponder()
        presenter.waitForEmailConfirmation().disposed(by: bag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bag = DisposeBag()
    }
}
    
extension PitEmailVerificationViewController: EmailConfirmationInterface {
    func updateLoadingViewVisibility(_ visibility: Visibility) {
        openMailButtonContainer.isLoading = visibility.isHidden == false
        waitingLabel.isHidden = visibility.isHidden
        guard visibility == .visible else { return }
        resendEmailActionableLabel.isHidden = visibility.isHidden == false
    }
    
    func sendEmailVerificationSuccess() {
        emailSentLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.emailSentLabel.isHidden = true
            self.resendEmailActionableLabel.isHidden = false
        }
    }
    
    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
        self.resendEmailActionableLabel.isHidden = false
    }
    
    func emailVerifiedSuccess() {
        verificationRelay.accept(())
    }
}

extension PitEmailVerificationViewController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        return trigger?.actionRange()
    }
    
    func actionRequestingExecution(label: ActionableLabel) {
        guard let trigger = trigger else { return }
        trigger.execute()
    }
}

extension PitEmailVerificationViewController: NavigatableView {
    var leftNavControllerCTAType: NavigationCTAType {
        return .none
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return .dismiss
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        dismiss(animated: true, completion: nil)
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        // no-op
    }
}
