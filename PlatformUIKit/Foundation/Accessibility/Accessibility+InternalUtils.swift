//
//  AccessibilityIdentifiers.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 12/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Accessibility {
    public struct Identifier {}
}

// MARK: - Public

public extension Accessibility.Identifier {
    
    /// General accessibility
    struct General {
        
        /// Main CTA button
        public static let mainCTAButton = "mainCTAButton"
        public static let secondaryCTAButton = "secondaryCTAButton"
        public static let destructiveCTAButton = "desctructiveCTAButton"
        
        // Segmented Button
        public static let primarySegmentedControl = "primarySegmentedControl"
    }
}

// MARK: - Internal

extension Accessibility.Identifier {
    struct NavigationBar {
        static let prefix = "NavigationBar."
        static let backButton = "\(prefix)backButton"
        static let drawerButton = "\(prefix)drawerButton"
        static let qrCodeButton = "\(prefix)qrCodeButton"
        static let dismissButton = "\(prefix)dismissButton"
    }
}

extension Accessibility.Identifier {
    struct IntroductionSheet {
        static let prefixFormat = "IntroductionSheet."
        static let titleLabel = "\(prefixFormat)titleLabel"
        static let subtitleLabel = "\(prefixFormat)subtitleLabel"
        static let doneButton = "\(prefixFormat)doneButton"
    }
}

extension Accessibility.Identifier {
    struct LoadingView {
        static let prefixFormat = "LoadingView."
        static let statusLabel = "\(prefixFormat)statusLabel"
        static let loadingView = "\(prefixFormat)loadingView"
    }
}

extension Accessibility.Identifier {
    struct ReceiveCrypto {
        private static let prefix = "ReceiveScreen."
        static let instructionLabel = "\(prefix)instructionLabel"
        static let addressLabel = "\(prefix)addressLabel"
        static let qrCodeImageView = "\(prefix)qrCodeImageView"
        static let enterPasswordButton = "\(prefix)enterPasswordButton"
    }
}

extension Accessibility.Identifier {
    struct TextFieldView {
        static let prefix = "TextFieldView."
        static let email = "\(prefix)statusLabel"
        static let newPassword = "\(prefix)newPassword"
        static let confirmNewPassword = "\(prefix)confirmNewPassword"
        static let password = "\(prefix)password"
        static let walletIdentifier = "\(prefix)walletIdentifier"
        static let recoveryPhrase = "\(prefix)recoveryPhrase"
    }
}

extension Accessibility.Identifier {
    struct SparklineView {
        static let prefix = "SparklineView"
    }
}

extension Accessibility.Identifier {
    struct MnemonicTextView {
        static let prefix = "MnemonicTextView."
        static let recoveryPhrase = "\(prefix)recoveryPhrase"
    }
}
