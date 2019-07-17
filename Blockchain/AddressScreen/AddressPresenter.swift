//
//  AddressPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift
import PlatformUIKit

// The presenter of the address screen
final class AddressPresenter {
    
    /// The name of the asset
    let assetName: String
    
    /// The representative image name of the asset
    let assetImageName: String
    
    /// The asset name label accessibility
    var titleAccessibility: Accessibility {
        return Accessibility(id: .value(AccessibilityIdentifiers.Address.assetNameLabel),
                            traits: .value(.header))
    }
    
    /// Relay that accepts and streams the address status
    private let statusRelay = BehaviorRelay<DisplayAddressStatus>(value: .awaitingFetch)
    
    /// The status of the address. Streams values on the `MainScheduler` by default
    var status: Observable<DisplayAddressStatus> {
        return statusRelay
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
    }
    
    /// View model for the copy button view
    let copyViewModel = SideImageButtonViewModel(
        accessibility: Accessibility(
            id: .value(AccessibilityIdentifiers.Address.copyButton),
            label: .value(LocalizationConstants.Address.Accessibility.copyButton),
            traits: .value(.button)
        )
    )
    
    /// View model for the share button view
    let shareViewModel = SideImageButtonViewModel(
        accessibility: Accessibility(
            id: .value(AccessibilityIdentifiers.Address.shareButton),
            label: .value(LocalizationConstants.Address.Accessibility.shareButton),
            traits: .value(.button)
        )
    )
    
    /// View model for the QR address view
    let qrAddressViewModel = QRAddressViewModel()
    
    /// Computed variable that returns the asset image.
    var assetImage: UIImage {
        return UIImage(named: assetImageName)!
    }
    
    /// Accepts and streams the raw address in order to share it
    private let addressShareRelay = PublishRelay<WalletAddressContent>()
    
    /// Observes the address for sharing purpose
    var addressShare: Observable<String> {
        return addressShareRelay
            .map { $0.string }
            .observeOn(MainScheduler.instance)
            .asObservable()
    }
    
    // MARK: - Services
    
    private let interactor: AddressInteracting
    private let pasteboard: Pasteboarding
    
    // MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: AddressInteracting,
         pasteboard: Pasteboarding = UIPasteboard.general) {
        self.interactor = interactor
        self.pasteboard = pasteboard
        let asset = interactor.asset
        assetImageName = asset.filledImageLargeName
        assetName = String(format: LocalizationConstants.Address.titleFormat, asset.description)
        
        setupCopyViewModel()
        setupShareViewModel()
        
        // Streams the status to the qr address view model
        status
            .bind(to: qrAddressViewModel.statusRelay)
            .disposed(by: disposeBag)
        
        status
            .map { $0.isReady }
            .bind(to: copyViewModel.isEnabledRelay,
                      shareViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        // Streams taps the address upon tapping copy button
        let copyTap = copyViewModel.tapRelay
            .withLatestFrom(status)
            .filter { $0.isReady }
            .map { $0.addressContent! }
        
        // The user is allowed tap either the QR address view or the copy button itself
        for copy in [qrAddressViewModel.copy, copyTap] {
            
            // Copy address and adjust view model's state
            copy
                .bind { [unowned self] content in
                    self.copy(addressContent: content)
                }
                .disposed(by: disposeBag)
            
            // Delay by Xs before switching its view model's state back
            copy
                .delay(.seconds(3), scheduler: MainScheduler.instance)
                .bind { [weak self] _ in
                    self?.setupCopyViewModel()
                }
                .disposed(by: disposeBag)
        }
        
        // Bind taps on share button
        shareViewModel.tapRelay
            .withLatestFrom(status)
            .filter { $0.isReady }
            .map { $0.addressContent! }
            .bind(to: addressShareRelay)
            .disposed(by: disposeBag)
        
        // Bind any received payment to `statusRelay`
        interactor.receivedPayment
            .map { _ -> DisplayAddressStatus in
                return .awaitingFetch
            }
            .asDriver(onErrorJustReturn: .awaitingFetch)
            .drive(statusRelay)
            .disposed(by: disposeBag)
    }
    
    /// Fetches new address and streams it using `status`.
    /// This method makes `status` to stream a valid value.
    func fetchAddress() {
        
        // Update the status
        statusRelay.accept(.fetching)
        
        // Get the next address
        interactor.address
            .map { content -> DisplayAddressStatus in
                return .readyForDisplay(content: content)
            }
            .catchError { error -> Single<DisplayAddressStatus> in
                switch error {
                case AddressFetchingError.unretainedSelf:
                    throw error
                case AddressFetchingError.absent:
                    return .just(.fetchFailure(localizedReason: LocalizationConstants.Address.loginToRefreshAddress))
                default:
                    return .just(.awaitingFetch)
                }
            }
            .subscribe(onSuccess: { [weak self] status in
                self?.statusRelay.accept(status)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Accessors
    
    private func copy(addressContent: WalletAddressContent) {
        
        // Copy the address
        pasteboard.string = addressContent.string
        
        // Set copy view model
        setCopyViewModelToCopiedState()
        
        // Make an impact feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    private func setupShareViewModel() {
        let theme = SideImageButtonViewModel.Theme(backgroundColor: .brandSecondary,
                                                   contentColor: .white,
                                                   imageName: "share_icon",
                                                   text: LocalizationConstants.Address.shareButton)
        shareViewModel.animate(theme: theme)
    }
    
    private func setCopyViewModelToCopiedState() {
        let theme = SideImageButtonViewModel.Theme(backgroundColor: .green,
                                                   contentColor: .white,
                                                   text: LocalizationConstants.Address.copiedButton)
        copyViewModel.animate(theme: theme)
    }
    
    private func setupCopyViewModel() {
        let theme = SideImageButtonViewModel.Theme(backgroundColor: .brandSecondary,
                                                    contentColor: .white,
                                                    imageName: "copy_icon",
                                                    text: LocalizationConstants.Address.copyButton)
        copyViewModel.animate(theme: theme)
    }
}
