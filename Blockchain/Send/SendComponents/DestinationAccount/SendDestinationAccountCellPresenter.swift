//
//  SendDestinationAccountCellPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import PlatformKit

/// The destination account presenter on the send screen
final class SendDestinationAccountCellPresenter {

    // MARK: - Types
    
    /// Describes the state of the destination account
    enum SelectionState {
        
        /// Input fed by keyboard or pasteboard
        case input(String)
        
        /// Pit account
        case pit
        
        /// Returns `true` for `.pit`
        var isPit: Bool {
            switch self {
            case .pit:
                return true
            case .input:
                return false
            }
        }
        
        /// Returns `.input("")`
        static var empty: SelectionState {
            return .input("")
        }
        
        /// Returns `true` for empty state
        var isEmpty: Bool {
            switch self {
            case .input(let value) where value.isEmpty:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Exposed Properties
    
    /// A placeholder for the destination text field
    let textFieldPlaceholder: String
    
    /// Streams a boolean on whether the PIT button should be visible
    var isPitButtonVisible: Observable<Bool> {
        return isPitButtonVisibleRelay
            .observeOn(MainScheduler.instance)
    }
    
    /// The image that represents the the PIT button.
    /// Streams on the main thread and replays the last element.
    var pitButtonImage: Driver<UIImage?> {
        return pitButtonImageRelay.asDriver()
    }
    
    /// Signals if the user has to configure 2FA in order to send to his PIT account
    var twoFAConfigurationAlertSignal: Signal<AlertViewPresenter.Content> {
        return twoFAConfigurationAlertRelay.asSignal()
    }
    
    /// Text field visibility.
    /// Streams on the main thread and replays the last element.
    var isTextFieldHidden: Driver<Bool> {
        return isTextFieldHiddenRelay.asDriver()
    }
    
    /// Cover text visibility.
    /// Streams on the main thread and replays the last element.
    var isCoverTextHidden: Driver<Bool> {
        return isCoverTextHiddenRelay.asDriver()
    }
    
    /// Streams the cover text for the label that covers the text field.
    /// Handy for accounts with value that shouldn't be displayed (e.g PIT).
    /// Streams on the main thread and replays the last element.
    var coverText: Driver<String> {
        return coverTextRelay.asDriver()
    }
    
    /// Publish relay for PIT button taps.
    /// Streams once the PIT address button is tapped
    let pitButtonTapRelay = PublishRelay<Void>()
    
    /// Signals once the address is scanned.
    /// Streams on the main thread and doesn't not replay elements.
    var scannedAddress: Signal<String> {
        return scannedAddressRelay.asSignal()
    }
    
    /// Streams the display destination address.
    /// 1. In case the selection state is `.input` it streams the address itself.
    /// 2. In case the selection state is output, it streams the cover text.
    var finalDisplayAddress: Observable<String> {
        return Observable.combineLatest(selectionStateRelay, coverTextRelay)
            .map { (state, text) -> String in
                switch state {
                case .input(let string):
                    return string
                case .pit:
                    return text
                }
            }
    }
    
    // MARK: - Private Properties

    // TODO: `scannedAddressRelay` should be used for selection from multiple accounts/addresses (an HD wallet)
    /// A publish relay for the scanned addresses (QRCode).
    private let scannedAddressRelay = PublishRelay<String>()
    
    /// The selection state for the destination address
    private let selectionStateRelay = BehaviorRelay<SelectionState>(value: .empty)
    
    /// Sends signals when the user taps the pit button while he still hasn't configured 2FA
    private let twoFAConfigurationAlertRelay = PublishRelay<AlertViewPresenter.Content>()
    
    private let isTextFieldHiddenRelay = BehaviorRelay<Bool>(value: false)
    private let isCoverTextHiddenRelay = BehaviorRelay<Bool>(value: true)
    private let isPitButtonVisibleRelay = BehaviorRelay<Bool>(value: false)
    private let pitButtonImageRelay = BehaviorRelay<UIImage?>(value: nil)
    private let coverTextRelay = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()

    // MARK: - Injected
    
    private let asset: AssetType
    private let interactor: SendDestinationAccountInteracting
    private let analyticsRecorder: AnalyticsEventRelayRecording
    
    // MARK: - Setup
    
    init(interactor: SendDestinationAccountInteracting,
         analyticsRecorder: AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        asset = interactor.asset
        self.analyticsRecorder = analyticsRecorder
        self.interactor = interactor
        
        // Setup text field placeholder
        textFieldPlaceholder = String(
            format: LocalizationConstants.Send.Destination.placeholder,
            asset.symbol
        )
        
        pitButtonTapRelay
            .map { AnalyticsEvents.Send.sendFormPitButtonClick(asset: interactor.asset) }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        // The selection state after the pit button tap
        let selectionStateAfterPitButtonTap = pitButtonTapRelay
            .withLatestFrom(selectionStateRelay)
            .map { $0.isPit }
            .map { $0 ? SelectionState.empty : SelectionState.pit }
        
        let twoFAConditionalSelectionState = Observable
            .combineLatest(interactor.isTwoFAConfigurationRequired, selectionStateAfterPitButtonTap)
        
        // Signal to show alert asking for 2FA configuration in case PIT button is tapped and 2FA is not configured
        twoFAConditionalSelectionState
            .filter { $0.0 }
            .map { _ in
                return AlertViewPresenter.Content(
                    title: LocalizationConstants.Errors.error,
                    message: LocalizationConstants.PIT.twoFactorNotEnabled
                )
            }
            .bind(to: twoFAConfigurationAlertRelay)
            .disposed(by: disposeBag)
        
        // Toggle PIT selection state upon each tap only if 2FA is not required to do so
        twoFAConditionalSelectionState
            .filter { !$0.0 }
            .map { $0.1 }
            .bind(to: selectionStateRelay)
            .disposed(by: disposeBag)
        
        // True if the current selection state is PIT
        let isPit = selectionStateRelay
            .map { $0.isPit }
        
        // Bind selection state to the PIT button image
        isPit
            .map { $0 ? "cancel_icon" : "pit_icon_small" }
            .map { UIImage(named: $0)! }
            .bind(to: pitButtonImageRelay)
            .disposed(by: disposeBag)
        
        // Bind text field visibility
         isPit
            .bind(to: isTextFieldHiddenRelay)
            .disposed(by: disposeBag)
        
        // Bind cover text visibility
        selectionStateRelay
            .map { !$0.isPit }
            .bind(to: isCoverTextHiddenRelay)
            .disposed(by: disposeBag)
        
        // Bind cover text value
        let symbol = asset.symbol
        isPit
            .map { $0 ? String(format: LocalizationConstants.Send.Destination.pitCover, symbol) : "" }
            .bind(to: coverTextRelay)
            .disposed(by: disposeBag)
        
        isPit
            .bind(to: interactor.pitSelectedRelay)
            .disposed(by: disposeBag)
        
        // Show PIT button only when the PIT account is valid,
        // AND the text field doesn't contain input or that PIT is already selected
        Observable
            .combineLatest(interactor.hasPitAccount, selectionStateRelay)
            .map { $0 && ($1.isEmpty || $1.isPit) }
            .bind(to: isPitButtonVisibleRelay)
            .disposed(by: disposeBag)
    }
    
    /// Called upon when the address field is being changed
    func addressFieldEdited(input: String, shouldPublish: Bool = false) {
        selectionStateRelay.accept(.input(input))
        interactor.set(address: input)
        if shouldPublish {
            scannedAddressRelay.accept(input)
        }
    }
    
    /// Performs any cleaning for the presnetation layer.
    func clean() {
        addressFieldEdited(input: "", shouldPublish: true)
    }
}
