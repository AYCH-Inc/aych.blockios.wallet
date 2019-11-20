//
//  Accessibility+TabItem.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

extension Accessibility.Identifier {
    struct TabItem {
        static let prefixFormat = "TabItem."
        static let home = "\(prefixFormat)home"
        static let activity = "\(prefixFormat)activity"
        static let swap = "\(prefixFormat)swap"
        static let send = "\(prefixFormat)send"
        static let request = "\(prefixFormat)request"
    }
}
