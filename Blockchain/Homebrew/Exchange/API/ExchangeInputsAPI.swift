//
//  ExchangeInputs.swift
//  Blockchain
//
//  Created by kevinwu on 8/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

protocol ExchangeInputsAPI: class {
    
    var activeInputValue: String { get }
    var inputViewModel: ExchangeInputViewModel { get set }
    var fiatValue: FiatValue? { get }
    var cryptoValue: CryptoValue? { get }
    var attributedInputValue: NSAttributedString { get }
    
    func canBackspace() -> Bool
    func canAdd(character: Character) -> Bool
    func add(character: Character)

    func clear()
    func backspace()
    func toggleInput(inputType: InputType, withOutput output: String)
}
