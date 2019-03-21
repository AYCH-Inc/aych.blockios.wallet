//
//  ExchangeInputsService.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit

// A class containing an active input that can switch values with an output using toggleInput()
class ExchangeInputsService: ExchangeInputsAPI {
    
    var inputViewModel: ExchangeInputViewModel
    
    private var components: [InputComponent] {
        return inputViewModel.components
    }
    
    var fiatValue: FiatValue? {
        return inputViewModel.fiatValue()
    }
    
    var cryptoValue: CryptoValue? {
        return inputViewModel.cryptoValue()
    }
    
    var inputType: InputType = .fiat {
        didSet {
            inputViewModel.inputType = inputType
        }
    }
    
    var activeInputValue: String {
        return inputViewModel.currentValue(includingSymbol: false)
    }
    
    init(inputType: InputType = .fiat) {
        inputViewModel = ExchangeInputViewModel(inputType: inputType)
    }
    
    var attributedInputValue: NSAttributedString {
        let font = Font(.branded(.montserratMedium), size: .custom(64))
        return NSAttributedString(
            string: inputViewModel.currentValue(),
            attributes: [.font: font.result]
        )
    }
    
    func canBackspace() -> Bool {
        return components.canDrop
    }
    
    func canAdd(character: Character) -> Bool {
        return inputViewModel.canAppend(character: character)
    }
    
    func add(character: Character) {
        inputViewModel.append(character: character)
    }
    
    func backspace() {
        inputViewModel.dropLast()
    }
    
    func toggleInput(inputType: InputType, withOutput output: String) {
        self.inputType = inputType
        inputViewModel.update(inputType: inputType, with: output)
    }

    func clear() {
        inputViewModel.clear()
    }
}
