//
//  AnnouncementRecord+Category.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

extension AnnouncementRecord {
    
    /// The category of the announcement
    enum Category: String, Codable {
        case persistent
        case periodic
        case oneTime
    }
}
