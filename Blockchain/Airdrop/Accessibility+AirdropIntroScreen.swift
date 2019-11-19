//
//  Accessibility+AirdropIntroScreen.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

extension Accessibility.Identifier {
    struct AirdropIntroScreen {
        private static let prefix = "AirdropIntro."
        static let amountLabel = "\(prefix)amountLabel"
        static let titleLabel = "\(prefix)titleLabel"
        static let subtitleLabel = "\(prefix)subtitleLabel"
        static let descriptionLabel = "\(prefix)descriptionLabel"
        
        struct InfoCell {
            private static let prefix = "\(AirdropIntroScreen.prefix)InfoCell."
            
            static let numberTitle = "\(prefix)numberTitle"
            static let numberValue = "\(prefix)numberValue"
            
            static let currencyTitle = "\(prefix)currencyTitle"
            static let currencyValue = "\(prefix)currencyValue"
        }
    }
}
