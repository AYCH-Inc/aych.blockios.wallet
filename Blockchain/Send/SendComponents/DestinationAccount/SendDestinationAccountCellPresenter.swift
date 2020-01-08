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
import ToolKit
import PlatformKit

/// The destination account presenter on the send screen
final class SendDestinationAccountCellPresenter {

    // MARK: - Types
    
    /// Describes the state of the destination account
    enum SelectionState {
        
        /// Input fed by keyboard or pasteboard
        case input(String)
        
        /// Exchange account
        case exchange
        
        /// Returns `true` for `.exchange`
        var isExchange: Bool {
            switch self {
            case .exchange:
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
    
    /// Streams a boolean on whether the exchange button should be visible
    var isExchangeButtonVisible: Observable<Bool> {
        return isExchangeButtonVisibleRelay
            .observeOn(MainScheduler.instance)
    }
    
    /// The image that represents the Exchange button.
    /// Streams on the main thread and replays the last element.
    var exchangeButtonImage: Driver<UIImage?> {
        return exchangeButtonImageRelay.asDriver()
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
    /// Handy for accounts with value that shouldn't be displayed (e.g Exchange).
    /// Streams on the main thread and replays the last element.
    var coverText: Driver<String> {
        return coverTextRelay.asDriver()
    }
    
    /// Publish relay for Exchange button taps.
    /// Streams once the exchange address button is tapped
    let exchangeButtonTapRelay = PublishRelay<Void>()
    
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
                case .exchange:
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
    
    /// Sends signals when the user taps the exchange button while he still hasn't configured 2FA
    private let twoFAConfigurationAlertRelay = PublishRelay<AlertViewPresenter.Content>()
    
    private let isTextFieldHiddenRelay = BehaviorRelay<Bool>(value: false)
    private let isCoverTextHiddenRelay = BehaviorRelay<Bool>(value: true)
    private let isExchangeButtonVisibleRelay = BehaviorRelay<Bool>(value: false)
    private let exchangeButtonImageRelay = BehaviorRelay<UIImage?>(value: nil)
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
        
        exchangeButtonTapRelay
            .map { AnalyticsEvents.Send.sendFormExchangeButtonClick(asset: interactor.asset) }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        // The selection state after the exchange button tap
        let selectionStateAfterExchangeButtonTap = exchangeButtonTapRelay
            .withLatestFrom(selectionStateRelay)
            .map { $0.isExchange }
            .map { $0 ? SelectionState.empty : SelectionState.exchange }
        
        let twoFAConditionalSelectionState = Observable
            .combineLatest(interactor.isTwoFAConfigurationRequired, selectionStateAfterExchangeButtonTap)
        
        // Signal to show alert asking for 2FA configuration in case Exchange button is tapped and 2FA is not configured
        twoFAConditionalSelectionState
            .filter { $0.0 }
            .map { _ in
                return AlertViewPresenter.Content(
                    title: LocalizationConstants.Errors.error,
                    message: LocalizationConstants.Exchange.twoFactorNotEnabled
                )
            }
            .bind(to: twoFAConfigurationAlertRelay)
            .disposed(by: disposeBag)
        
        // Toggle Exchange selection state upon each tap only if 2FA is not required to do so
        twoFAConditionalSelectionState
            .filter { !$0.0 }
            .map { $0.1 }
            .bind(to: selectionStateRelay)
            .disposed(by: disposeBag)
        
        // True if the current selection state is PIT
        let isExchange = selectionStateRelay
            .map { $0.isExchange }
        
        // Bind selection state to the Exchange button image
        isExchange
            .map { $0 ? "cancel_icon" : "exchange-icon-small" }
            .map { UIImage(named: $0)! }
            .bind(to: exchangeButtonImageRelay)
            .disposed(by: disposeBag)
        
        // Bind text field visibility
         isExchange
            .bind(to: isTextFieldHiddenRelay)
            .disposed(by: disposeBag)
        
        // Bind cover text visibility
        selectionStateRelay
            .map { !$0.isExchange }
            .bind(to: isCoverTextHiddenRelay)
            .disposed(by: disposeBag)
        
        // Bind cover text value
        let symbol = asset.symbol
        isExchange
            .map { $0 ? String(format: LocalizationConstants.Send.Destination.exchangeCover, symbol) : "" }
            .bind(to: coverTextRelay)
            .disposed(by: disposeBag)
        
        isExchange
            .bind(to: interactor.exchangeSelectedRelay)
            .disposed(by: disposeBag)
        
        // Show Exchange button only when the Exchange account is valid,
        // AND the text field doesn't contain input or that Exchange is already selected
        Observable
            .combineLatest(interactor.hasExchangeAccount, selectionStateRelay)
            .map { $0 && ($1.isEmpty || $1.isExchange) }
            .bind(to: isExchangeButtonVisibleRelay)
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
