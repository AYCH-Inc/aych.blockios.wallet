//
//  SendXLMInterface.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SendXLMInterface: class {
    func updateActivityIndicator(_ visibility: Visibility)
    func errorIndicator(_ visibility: Visibility)
    func errorLabelText(_ value: String)
    func continueButtonEnabled(_ value: Bool)
    func updateActionableLabel(trigger: ActionableTrigger)
    func useTotalPromptText(_ value: String)
    func feeLabelText(_ value: String)
    func stellarAddressText(_ value: String)
}
