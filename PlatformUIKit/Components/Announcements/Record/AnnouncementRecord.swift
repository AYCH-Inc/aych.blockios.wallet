//
//  AnnouncementRecord.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// The announcement dismissal / approval record
public struct AnnouncementRecord: Codable {
    
    enum DisplayState {
        case show
        case hide
        case conditional(lastDismissalDate: Date, dismissalsSoFar: Int)
    }
    
    // MARK: - Properties
    
    /// The dismissal state of the record
    let state: State
    
    /// The category of the announcement
    let category: Category
    
    /// Returns the display state: whether the announcement can be displayed, depending on the following factors -
    /// Category, Dismissal Date, Current Date
    var displayState: DisplayState {
        switch (category, state) {
        case (_, .valid): // Any category with valid state
            return .show
        case (_, .removed):
            return .hide
        case (.periodic, .dismissed(on: let date, count: let count)):
            return .conditional(lastDismissalDate: date, dismissalsSoFar: count)
        default: // Any other value should result in hiding the announcement
            return .hide
        }
    }
}
