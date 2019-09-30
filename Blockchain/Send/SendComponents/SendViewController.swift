//
//  SendViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay
import RxCocoa
import SafariServices

/// This class was designed to replace all current send screens
/// Should contain as little logic as possible. It's only a view
final class SendViewController: UIViewController {

    // MARK: - Types
    
    typealias CellIndex = SendPresenter.TableViewDataSource.CellIndex
    
    // MARK: - UI Properties
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var continueButton: PrimaryButtonContainer!

    private lazy var keyboardBar: UIToolbar = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let bar = UIToolbar()
        bar.items = [flexibleSpace, doneButton]
        bar.sizeToFit()
        return bar
    }()
    
    // MARK: - Injected
    
    fileprivate let alertPresenter: AlertViewPresenter
    private let modalPresenter: ModalPresenter
    private let presenter: SendPresenter
    private let recorder: Recording
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    // TODO: Remove modal presenter dependency
    init(presenter: SendPresenter,
         alertPresenter: AlertViewPresenter = .shared,
         modalPresenter: ModalPresenter = .shared,
         recorder: Recording = CrashlyticsRecorder()) {
        self.presenter = presenter
        self.alertPresenter = alertPresenter
        self.modalPresenter = modalPresenter
        self.recorder = recorder
        super.init(nibName: type(of: self).objectName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestureRecognizer()
        setupTableView()
        setupContinueButton()
        setupNavigationRightButton()
        setupErrorHandling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.clean()
    }
    
    // MARK: - Setup
    
    private func setupErrorHandling() {
        presenter.error
            .emit(to: rx.errorHandler)
            .disposed(by: disposeBag)
        presenter.alert
            .emit(to: rx.alertHandler)
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationRightButton() {
        presenter.navigationRightButton
            .bind { [weak self] update in
                if let navigationController = self?.navigationController as? BaseNavigationController {
                    navigationController.update()
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event
            .bind { [unowned self] _ in
                self.dismissKeyboard()
            }
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.separatorInset = .zero
        tableView.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.registerNibCells(
            SendDestinationAccountTableViewCell.identifier,
            SendSourceAccountTableViewCell.identifier,
            SendFeeTableViewCell.identifier,
            SendAmountTableViewCell.identifier
        )
    }
    
    private func setupContinueButton() {
        continueButton.title = LocalizationConstants.Send.primaryButton
        continueButton.disabledButtonBackgroundColor = continueButton.disabledButtonBackgroundColor.withAlphaComponent(0.6)
        continueButton.rx.tap
            .bind { [unowned self] in
                self.continueButtonTapped()
            }
            .disposed(by: disposeBag)
        presenter.isContinueButtonEnabled
            .drive(continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func handle(error: SendInputState.StateError) {
        dismissKeyboard()
        let alert = AlertModel(
            headline: error.title(for: presenter.asset),
            body: error.description(for: presenter.asset),
            image: presenter.asset.errorImage,
            style: .sheet
        )
        let alertView = AlertView.make(with: alert, completion: nil)
        alertView.show()
    }
    
    // TODO: Refactor this once `BCConfirmPaymentView` is written in `Swift`
    // The confirmation screen should be enqeued normally into a navigation controller.
    private func continueButtonTapped() {
        presenter.prepareForSending()
            .subscribe(onSuccess: { [weak self] viewModel in
                guard let self = self else { return }
                let confirmView = BCConfirmPaymentView(
                    frame: self.view.frame,
                    viewModel: viewModel,
                    sendButtonFrame: self.continueButton.frame
                    )!
                confirmView.confirmDelegate = self
                self.modalPresenter.showModal(
                    withContent: confirmView,
                    closeType: ModalCloseTypeBack,
                    showHeader: true,
                    headerText: LocalizationConstants.SendAsset.confirmPayment
                )
            }, onError: { [weak self] error in
                self?.recorder.error(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func displaySuccessAlert() {
        let alert = AlertModel(
            headline: LocalizationConstants.success,
            body: LocalizationConstants.SendAsset.paymentSent,
            image: presenter.asset.successImage,
            style: .sheet
        )
        let alertView = AlertView.make(with: alert, completion: nil)
        alertView.show()
    }
}

// MARK: - ConfirmPaymentViewDelegate

extension SendViewController: ConfirmPaymentViewDelegate {
    func confirmButtonDidTap(_ note: String?) {
        presenter.sendButtonTapped()
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.displaySuccessAlert()
                self.modalPresenter.closeAllModals()
                self.presenter.clean()
                }, onError: { [weak self] error in
                    self?.handle(error: SendInputState.StateError(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    // TODO: Implement or remove
    func feeInformationButtonClicked() {}
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SendPresenter.TableViewDataSource.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case CellIndex.source:
            let cell: SendSourceAccountTableViewCell = tableView.dequeue(
                SendSourceAccountTableViewCell.identifier,
                for: indexPath
            )
            cell.presenter = presenter.sourcePresenter
            return cell
        case CellIndex.destination:
            let cell: SendDestinationAccountTableViewCell = tableView.dequeue(
                SendDestinationAccountTableViewCell.identifier,
                for: indexPath
            )
            cell.presenter = presenter.destinationPresenter
            cell.prepare(using: keyboardBar)
            return cell
        case CellIndex.amount:
            let cell: SendAmountTableViewCell = tableView.dequeue(
                SendAmountTableViewCell.identifier, for: indexPath
            )
            cell.presenter = presenter.amountPresenter
            cell.prepare(using: keyboardBar)
            return cell
        case CellIndex.fee:
            let cell: SendFeeTableViewCell = tableView.dequeue(
                SendFeeTableViewCell.identifier,
                for: indexPath
            )
            cell.presenter = presenter.feePresenter
            return cell
        default: // Must not arrive here
            recorder.error("unexpected row \(indexPath.row)")
            return UITableViewCell()
        }
    }
}

// MARK: - NavigatableView

extension SendViewController: NavigatableView {
    var rightNavControllerCTAType: NavigationCTAType {
        return presenter.navigationRightButtonValue.indicator.button
    }
    
    var rightCTATintColor: UIColor {
        return presenter.navigationRightButtonValue.color
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        presenter.navigationRightButtonTapped()
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        presenter.navigationLeftButtonTapped()
    }
}

// MARK: - Rx

extension Reactive where Base: SendViewController {
    
    /// Binder for the error handling
    fileprivate var errorHandler: Binder<SendInputState.StateError> {
        return Binder(base) { viewController, error in
            viewController.handle(error: error)
        }
    }
    
    /// Binder for any alert
    fileprivate var alertHandler: Binder<AlertViewPresenter.Content> {
        return Binder(base) { viewController, content in
            viewController.alertPresenter.notify(content: content)
        }
    }
}
