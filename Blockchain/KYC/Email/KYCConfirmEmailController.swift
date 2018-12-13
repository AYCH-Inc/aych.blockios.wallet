//
//  KYCConfirmEmailController.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCConfirmEmailController: KYCBaseViewController, BottomButtonContainerView, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 0.3

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = 0
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var labelHeader: UILabel!
    @IBOutlet private var labelSubHeader: UILabel!
    @IBOutlet private var labelFooter: UILabel!
    @IBOutlet private var validationTextFieldEmail: ValidationTextField!
    @IBOutlet private var primaryButton: PrimaryButtonContainer!

    // MARK: Private Properties

    private lazy var presenter: KYCVerifyEmailPresenter = {
        return KYCVerifyEmailPresenter(view: self)
    }()

    // MARK: Properties

    var email: EmailAddress = "" {
        didSet {
            guard isViewLoaded else { return }
            validationTextFieldEmail.text = email
        }
    }

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCConfirmEmailController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .confirmEmail
        return controller
    }

    // MARK: - UIViewController Lifecycle Methods

    deinit {
        cleanUp()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeader.text = LocalizationConstants.KYC.checkYourInbox
        labelSubHeader.text = LocalizationConstants.KYC.confirmEmailExplanation
        labelFooter.text = LocalizationConstants.KYC.didntGetTheEmail
        validationTextFieldEmail.text = email
        validationTextFieldEmail.isEnabled = false
        primaryButton.actionBlock = { [unowned self] in
            self.primaryButtonTapped()
        }
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        presenter.listenForEmailConfirmation()
    }

    // MARK: - Actions

    private func primaryButtonTapped() {
        guard case .valid = validationTextFieldEmail.validate() else {
            validationTextFieldEmail.becomeFocused()
            Logger.shared.warning("email field is invalid.")
            return
        }
        guard let email = validationTextFieldEmail.text else {
            Logger.shared.warning("number is nil.")
            return
        }
        presenter.sendVerificationEmail(to: email)
    }
}

extension KYCConfirmEmailController: KYCConfirmEmailView {
    func showLoadingView() {
        primaryButton.isLoading = true
    }

    func sendEmailVerificationSuccess() {
        AlertViewPresenter.shared.standardNotify(message: LocalizationConstants.KYC.emailSent, title: LocalizationConstants.information)
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func hideLoadingView() {
        primaryButton.isLoading = false
    }

    func emailVerifiedSuccess() {
        Logger.shared.info("Email is verified.")
        coordinator.handle(event: .nextPageFromPageType(pageType, nil))
    }
}
