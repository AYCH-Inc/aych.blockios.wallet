//
//  AnalyticsEvent+Announcement.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct AnalyticsEvents {
    struct Announcement: AnalyticsEvent {
        enum Name: String {
            case shown = "card_shown"
            case actioned = "card_actioned"
            case dismissed = "card_dismissed"
        }
        
        enum ParamKey: String {
            case title = "card_title"
        }
    
        let name: String
        let params: [String : String]?
        
        init(name: Name, type: AnnouncementType) {
            self.name = name.rawValue
            self.params = [ParamKey.title.rawValue: type.rawValue]
        }
    }
}
