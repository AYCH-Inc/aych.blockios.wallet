//
//  AnnouncementRecorder.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// A class that records dismiss actions taken by the user when dismissing an announcement.
/// We record the dismissal so that it wouldn't be shown again in case it has already been shown once.
/// - Tag: `AnnouncementRecorder`
final class AnnouncementRecorder {

    // MARK: - Types

    // MARK: - Properties
    
    private var cache: CacheSuite
    
    /// Key subscript for an entry
    subscript(key: AnnouncementRecord.Key) -> Entry {
        return Entry(recorder: self, key: key)
    }
    
    // MARK: - Setup
    
    init(cache: CacheSuite = UserDefaults.standard) {
        self.cache = cache
    }
}

// MARK: - Legacy

extension AnnouncementRecorder {
    
    /// Perform one time migration of announcement keys
    static func migrate() {
        let userDefaults = UserDefaults.standard
        
        struct KeyCategoryPair {
            let legacyKey: AnnouncementRecord.LegacyKey
            let category: AnnouncementRecord.Category
        }
        
        [KeyCategoryPair(legacyKey: .shouldHidePITLinkingCard, category: .oneTime),
         KeyCategoryPair(legacyKey: .hasSeenPAXCard, category: .oneTime)]
            .filter { return userDefaults.value(forKey: $0.legacyKey.rawValue) as? Bool ?? false }
            .filter { $0.legacyKey.key != nil }
            .forEach {
                let recorder = AnnouncementRecorder(cache: userDefaults)
                recorder[$0.legacyKey.key!].markDismissed(category: $0.category)
            }
    }
    
    /// Resets the announcements entirely by clearing any announcements from user defaults
    static func reset() {
        for key in AnnouncementRecord.Key.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}

// MARK: - Entry

extension AnnouncementRecorder {
    
    /// Cached entry for which announcement dismissal is recorded
    final class Entry: Hashable, Equatable {
        
        // MARK: - Properties
        
        /// Returns the display state as per announcement
        /// If the record was not kept in cache - it's safe to assume it's a new record
        var displayState: AnnouncementRecord.DisplayState {
            return value(for: key)?.displayState ?? .show
        }
        
        private let errorRecorder: ErrorRecording
        private unowned let recorder: AnnouncementRecorder
        
        /// The key to the cache suite
        private let key: AnnouncementRecord.Key
        
        // MARK: - Setup
        
        init(errorRecorder: ErrorRecording = CrashlyticsRecorder(),
             recorder: AnnouncementRecorder,
             key: AnnouncementRecord.Key) {
            self.errorRecorder = errorRecorder
            self.recorder = recorder
            self.key = key
        }
        
        /// Marks the announcement as removed by keeping it in cache
        /// along with its category, dismissal date, and number of dismissals so far.
        /// - parameter category: the category of the announcement
        func markRemoved(category: AnnouncementRecord.Category) {
            let record = AnnouncementRecord(state: .removed, category: category)
            save(record: record)
        }
        
        /// Marks the announcement as dismissed by keeping it in cache
        /// along with its category, dismissal date, and number of dismissals so far.
        /// - parameter category: the category of the announcement
        func markDismissed(category: AnnouncementRecord.Category) {
            
            // Calculate number of dismissals
            let dismissalCount: Int
            switch value(for: key)?.state {
            case .some(.dismissed(on: _, count: let count)):
                dismissalCount = count + 1
            default:
                dismissalCount = 1
            }
            
            // Prepare a record with the current time as dismissal date and count of dismissals
            let record = AnnouncementRecord(
                state: .dismissed(on: Date(), count: dismissalCount),
                category: category
            )
            save(record: record)
        }
        
        // MARK: - Accessors
        
        private func save(record: AnnouncementRecord) {
            do {
                let data = try record.encode()
                recorder.cache.set(data, forKey: key.rawValue)
            } catch {
                errorRecorder.error(error)
            }
        }
        
        private func value(for key: AnnouncementRecord.Key) -> AnnouncementRecord? {
            guard let data = recorder.cache.data(forKey: key.rawValue) else {
                return nil
            }
            return try? data.decode(to: AnnouncementRecord.self)
        }

        // MARK: Hashable
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }
        
        // MARK: - Equatable
        
        static func == (lhs: AnnouncementRecorder.Entry,
                        rhs: AnnouncementRecorder.Entry) -> Bool {
            return lhs.key == rhs.key
        }
    }
}
