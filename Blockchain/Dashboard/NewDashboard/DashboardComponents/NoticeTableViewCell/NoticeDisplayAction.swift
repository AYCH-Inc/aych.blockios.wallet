//
//  NoticePresentationState.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

/// Notice display action
enum NoticeDisplayAction: Equatable {
    
    /// No statement should be presented
    case hide
    
    /// Value of statement with text and optional image name
    case show(NoticeViewModel)
    
    /// Returns the view model
    var viewModel: NoticeViewModel? {
        switch self {
        case .show(let viewModel):
            return viewModel
        case .hide:
            return nil
        }
    }
}
