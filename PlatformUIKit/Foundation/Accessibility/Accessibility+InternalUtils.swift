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
    }
}

// MARK: - Internal

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
