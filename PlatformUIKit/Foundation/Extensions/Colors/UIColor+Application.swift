//
//  UIColor+Application.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// MARK: - Color Palette - App Layer

public extension UIColor {
    
    // Primary
    
    static let primary = blue900
    static let secondary = blue600
    static let tertiary = blue400

    // Navigation
    
    static let navigationBarBackground = blue900
    
    // Backgrounds & Borders
    
    static let background = grey000
    static let lightBorder = grey000
    static let mediumBorder = grey100
    
    // Indications
    
    static let securePinGrey = greyFade400
    static let addressPageIndicator = blue100

    // MARK: Texts
    
    static let titleText = grey800
    static let descriptionText = grey600
    static let mutedText = grey400
    
    // Buttons
    
    static let destructiveButton = red600
    static let successButton = green600
    static let primaryButton = blue600
    static let secondaryButton = grey800

    static let iconDefault = grey400
    static let iconSelected = grey400
    
    // Crypto
    
    static let bitcoin = btc
    static let ethereum = eth
    static let bitcoinCash = bch
    static let stellar = xlm
    static let paxos = pax
    
    // Tiers
    
    static let silverTier = tiersSilver
    static let goldTier = tiersGold
    static let diamondTier = tiersDiamond
}
