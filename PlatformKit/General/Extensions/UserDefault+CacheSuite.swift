//
//  UserDefault+CacheSuite.swift
//  PlatformKit
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A suite that can cache values for any purpose
public protocol CacheSuite {
    
    /// Returns a boolean value for key
    func bool(forKey key: String) -> Bool
    
    /// Keeps boolean value for key
    func set(_ value: Bool, forKey key: String)
}

extension UserDefaults: CacheSuite {}

/// In-memory cache suite - provides a mocking functionality for user defaults
public class MemoryCacheSuite: CacheSuite {
    
    // MARK: - Properties
    
    private var cache: [String: Any]
    
    // MARK: - Setup
    
    public init(cache: [String: Any] = [:]) {
        self.cache = cache
    }
    
    // MARK: - API
    
    public func bool(forKey key: String) -> Bool {
        return cache[key] as? Bool ?? false
    }
    
    public func set(_ value: Bool, forKey key: String) {
        return cache[key] = value
    }
}
