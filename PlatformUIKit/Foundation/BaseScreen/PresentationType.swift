//
//  PresentationType.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 02/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The type of the presentation
public enum PresentationType {
    
    /// Presents a modal over a given view controller
    case modal(from: ViewControllerAPI)
    
    /// Presents a modal over the top most view controller
    case modalOverTopMost
    
    /// Navigates from a given view controller
    case navigation(from: ViewControllerAPI)
    
    /// Navigates from the current view controller
    case navigationFromCurrent
    
    public var leadingButton: Screen.Style.LeadingButton {
        switch self {
        case .modal, .modalOverTopMost:
            return .close
        case .navigation, .navigationFromCurrent:
            return .back
        }
    }
}
