//
//  NavigationCTA.swift
//  Blockchain
//
//  Created by Chris Arriola on 1/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum NavigationCTA {
    case dismiss
    case help
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            return #imageLiteral(resourceName: "close.png")
        case .help:
            return #imageLiteral(resourceName: "icon_help.pdf")
        case .none:
            return nil
        }
    }

    var visibility: Visibility {
        switch self {
        case .dismiss:
            return .visible
        case .help:
            return .visible
        case .none:
            return .hidden
        }
    }
}
