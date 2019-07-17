//
//  DigitPadViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

final class DigitPadViewModel {
    
    // MARK: - Properties
    
    /// The digits sorted by index (i.e 0 index represents zero-digit, 5 index represents the fifth digit)
    let digitButtonViewModelArray: [DigitPadButtonViewModel]
    
    /// Backspace button
    let backspaceButtonViewModel: DigitPadButtonViewModel
    
    /// Custom button, is located on the bottom-left side of the pad
    let customButtonViewModel: DigitPadButtonViewModel
    
    /// Relay for bottom leading button taps
    private let customButtonTapRelay = PublishRelay<Void>()
    var customButtonTapObservable: Observable<Void> {
        return customButtonTapRelay.asObservable()
    }
    
    /// Relay for pin value. subscribe to it to get the pin stream
    private let valueRelay = BehaviorRelay<String>(value: "")
    var valueObservable: Observable<String> {
        return valueRelay.asObservable()
    }
    
    /// Observes the current length of the value
    let valueLengthObservable: Observable<Int>
    
    /// Relay for tapping
    private let valueInsertedPublishRelay = PublishRelay<Void>()
    var valueInsertedObservable: Observable<Void> {
        return valueInsertedPublishRelay.asObservable()
    }
    
    /// The raw `String` value
    var value: String {
        return valueRelay.value
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(maxDigitCount: Int = 4,
         customButtonViewModel: DigitPadButtonViewModel = .empty,
         contentTint: UIColor = .black,
         buttonHighlightColor: UIColor = .clear) {

        let buttonBackground = DigitPadButtonViewModel.Background(highlightColor: buttonHighlightColor)
        
        // Initialize all buttons
        digitButtonViewModelArray = (0...9).map {
            return DigitPadButtonViewModel(content: .label(text: "\($0)", tint: contentTint), background: buttonBackground)
        }

        backspaceButtonViewModel = DigitPadButtonViewModel(content: .image(type: .backspace, tint: contentTint),
                                                           background: buttonBackground)
        self.customButtonViewModel = customButtonViewModel
        
        // Digit count of the value
        valueLengthObservable = valueRelay.map { $0.count }.share(replay: 1)
        
        // Bind backspace to an action
        backspaceButtonViewModel.tapObservable
            .bind { [unowned self] _ in
                let value = String(self.valueRelay.value.dropLast())
                self.valueRelay.accept(value)
            }.disposed(by: disposeBag)
        
        // Bind taps on the bottom left view to an action
        customButtonViewModel.tapObservable
            .map { _ in Void() }
            .bind(to: customButtonTapRelay)
            .disposed(by: disposeBag)

        // Merge all digit observables into one stream of digits
        let tapObservable = Observable.merge(digitButtonViewModelArray.map { $0.tapObservable })
        tapObservable
            .bind { [unowned self] content in
                switch content {
                case .label(text: let digit, tint: _) where self.value.count < maxDigitCount:
                    self.valueRelay.accept("\(self.value)\(digit)")
                case .label, .image, .none:
                    break
                }
                if self.value.count == maxDigitCount {
                    self.valueInsertedPublishRelay.accept(Void())
                }
            }.disposed(by: disposeBag)
    }
    
    /// Resets the pin to a given value
    func reset(to value: String = "") {
        valueRelay.accept(value)
        valueInsertedPublishRelay.accept(Void())
    }
}

