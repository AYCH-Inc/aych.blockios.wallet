//
//  AnnouncementSequence.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A sequence of announcement candidates
struct AnnouncementSequence: Sequence, IteratorProtocol {
    
    // MARK: - Properties
    
    private var index = 0
    private var announcements: [Announcement]
    
    // MARK: - Setup
    
    init(announcements: [Announcement] = []) {
        self.announcements = announcements
    }
    
    // MARK: - Sequence
    
    /// Computes the next announcement that can be shown to the user
    mutating func next() -> Announcement? {
        let index = announcements.firstIndex { $0.shouldShow }
        if let index = index {
            self.index = index
            return announcements.remove(at: index)
        }
        return nil
    }
    
    // MARK: - Accessors
    
    /// Resets the sequence to a given announcement array
    mutating func reset(to announcements: [Announcement]) {
        self.index = 0
        self.announcements = announcements
    }
}
