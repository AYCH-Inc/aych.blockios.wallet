//
//  Accessibility+Airdrop.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

extension Accessibility.Identifier {
    struct AirdropCenterScreen {
        static let prefix = "AirdropCenterScreen."
        struct Cell {
            static let prefix = "\(AirdropCenterScreen.prefix)Cell."
            static let image = "\(prefix)image-"
            static let title = "\(prefix)title-"
            static let description = "\(prefix)description-"
        }
    }
    
    struct AirdropStatusScreen {
        private static let prefix = "AirdropStatusScreen."
        static let backgroundImageView = "\(prefix)backgroundImageView"
        static let thumbImageView = "\(prefix)thumbImageView"
        static let titleLabel = "\(prefix)titleLabel"
        static let descriptionLabel = "\(prefix)descriptionLabel"
        
        struct Cell {
            private static let prefix = "\(AirdropStatusScreen.prefix)Cell."
            struct Status {
                private static let prefix = "\(Cell.prefix)Status."
                static let title = "\(prefix)title"
                static let value = "\(prefix)value"
            }
            struct Amount {
                private static let prefix = "\(Cell.prefix)Amount."
                static let title = "\(prefix)title"
                static let value = "\(prefix)value"
            }
            struct Date {
                private static let prefix = "\(Cell.prefix)Date."
                static let title = "\(prefix)title"
                static let value = "\(prefix)value"
            }
        }
    }
}
