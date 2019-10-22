//
//  FormPresentationStateReducer.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public final class FormPresentationStateReducer {
    
    // MARK: - Types
    
    public enum ReducingError: Error {
        
        /// Imput sent to reducer is an empty collection
        case forbiddenEmptyInput
        
        /// Unexpectedly, could not reduce the input into `FormPresentationState`
        case unreduceableInput
    }
    
    // MARK: - Setup
    
    public init() {}
    
    // MARK: - API
    
    public func reduce(states: [TextFieldViewModel.State]) throws -> FormPresentationState {
        guard !states.isEmpty else { throw ReducingError.forbiddenEmptyInput }
        if states.count > 1 && states.areAllElements(equal: .valid(value: "")) {
            return .valid
        }
        if states.contains(.empty) {
            return .invalid(.emptyTextField)
        }
        if states.contains(.invalid) {
            return .invalid(.invalidTextField)
        }
        if states.contains(.mismatchError) {
            return .invalid(.mismatch)
        }
        return .valid
    }
}
