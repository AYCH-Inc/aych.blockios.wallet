//
//  WalletIntroductionLocation.swift
//  Blockchain
//
//  Created by AlexM on 8/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `WalletIntroductionLocation` denotes the screen as well as the
/// location that the event should map to. This is saved in the file system
/// as the user completes introduction events so that we know where the user
/// left off.
struct WalletIntroductionLocation: Codable, Comparable {
    
    enum Screen: Int, Codable, Comparable {
        case dashboard
        case sideMenu
    }
    
    enum Position: Int, Codable, Comparable {
        case home
        case send
        case request
        case swap
        case buySell
    }
    
    let screen: Screen
    let position: Position
    
    init(screen: Screen, position: Position) {
        self.screen = screen
        self.position = position
    }
}

extension WalletIntroductionLocation {
    static func < (lhs: WalletIntroductionLocation, rhs: WalletIntroductionLocation) -> Bool {
        if lhs.screen == rhs.screen {
            return lhs.position < rhs.position
        } else {
            return lhs.screen < rhs.screen
        }
    }
    
    static func > (lhs: WalletIntroductionLocation, rhs: WalletIntroductionLocation) -> Bool {
        if lhs.screen == rhs.screen {
            return lhs.position > rhs.position
        } else {
            return lhs.screen > rhs.screen
        }
    }
}

extension WalletIntroductionLocation.Screen {
    static func < (lhs: WalletIntroductionLocation.Screen, rhs: WalletIntroductionLocation.Screen) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: WalletIntroductionLocation.Screen, rhs: WalletIntroductionLocation.Screen) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}

extension WalletIntroductionLocation.Position {
    static func < (lhs: WalletIntroductionLocation.Position, rhs: WalletIntroductionLocation.Position) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func > (lhs: WalletIntroductionLocation.Position, rhs: WalletIntroductionLocation.Position) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}

extension WalletIntroductionLocation {
    /// The location that the user should start at on first launch. 
    static let starter: WalletIntroductionLocation = WalletIntroductionLocation(screen: .dashboard, position: .home)
}
