//
//  DateFormatter+Conveniences.swift
//  PlatformKit
//
//  Created by AlexM on 5/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension DateFormatter {
    public static let iso8601Format: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    public static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    public static var nominalReadable: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM. dd, yyyy"
        return formatter
    }
    
    public static func ddMMyyyy(separatedBy separator: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd\(separator)MM\(separator)yyyy"
        return formatter
    }

    /// The format that the server sends down the expiration date for session tokens
    public static let sessionDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    /// The API expects the user's DOB to be formatted
    /// this way.
    public static let birthday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let HTTPRequestDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SS'Z'"
        return formatter
    }()
}
