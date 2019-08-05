//
//  AnnouncementDismissRecorder.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// A class that records dismiss actions taken by the user when dismissing an announcement.
/// We record the dismissal so that it wouldn't be shown again in case it has already been shown once.
final class AnnouncementDismissRecorder {

    // MARK: - Properties
    
    private var cache: CacheSuite
    
    /// Key subscript for an entry
    subscript(key: String) -> Entry {
        return Entry(recorder: self, key: key)
    }
    
    // MARK: - Setup
    
    init(cache: CacheSuite = UserDefaults.standard) {
        self.cache = cache
    }
}

extension AnnouncementDismissRecorder {
    
    /// Cached entry for which announcement dismissal is recorded
    final class Entry: Hashable, Equatable {
        
        // MARK: - Properties
        
        private unowned let recorder: AnnouncementDismissRecorder
        
        /// The key to the cache suite
        private let key: String
        
        /// Keep in cache whether the announcement was dismissed
        private(set) var value: Bool {
            get {
                return recorder.cache.bool(forKey: key)
            }
            set {
                recorder.cache.set(newValue, forKey: key)
            }
        }
        
        /// Is the announcement dismissed
        var isDismissed: Bool {
            return value
        }
        
        // MARK: - Setup
        
        init(recorder: AnnouncementDismissRecorder, key: String) {
            self.recorder = recorder
            self.key = key
        }
        
        /// Marks the announcement as dismissed by keeping it in cache
        func markDismissed() {
            value = true
        }
        
        // MARK: Hashable
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }
        
        // MARK: - Equatable
        
        static func == (lhs: AnnouncementDismissRecorder.Entry,
                        rhs: AnnouncementDismissRecorder.Entry) -> Bool {
            return lhs.key == rhs.key
        }
    }
}
