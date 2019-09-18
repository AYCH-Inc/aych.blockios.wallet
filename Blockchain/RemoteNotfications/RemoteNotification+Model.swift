//
//  RemoteNotification+Model.swift
//  Blockchain
//
//  Created by Daniel Huri on 09/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Embeds any nesting types: e.g topics and types of notifications
struct RemoteNotification {
    
    /// Remote notification token representation
    typealias Token = String
    
    /// Potential errors during token fetching
    enum TokenFetchError: Error {
        
        /// Embeds any firebase error
        case external(Error)
        
        /// Token is empty
        case tokenIsEmpty
        
        /// Result is nullified
        case resultIsNil
    }

    /// A data bag for push notification format
    enum NotificationType {
        
        // MARK: - Cases
        
        /// Received bitcoin transaction
        case bitcoinTransactionReceived
        
        /// TODO: Delete this once the type logic is handled (parsing & generalizing)
        case general
        
        // MARK: - Setup
        
        // TODO: Parse data into readable format. Consider creating a parser to do it
        init(using info: [String: Any]) {
            self = .general
        }
    }
    
    // TODO: Add topics here
    enum Topic: String {
        case todo = "todo_topics"
    }
}
