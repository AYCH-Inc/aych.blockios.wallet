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
    
    // MARK: - Boolean
    
    /// Returns a boolean value for key
    func bool(forKey key: String) -> Bool
    
    /// Keeps boolean value for key
    func set(_ value: Bool, forKey key: String)
    
    // MARK: - Data
    
    /// Returns data value for key
    func data(forKey defaultName: String) -> Data?
    
    /// Keeps `Any?` value for key
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: CacheSuite {}

/// In-memory cache suite - provides a mocking functionality for user defaults
public class MemoryCacheSuite: CacheSuite {

    // MARK: - Properties
    
    private var cache: [String: Any?]
    
    // MARK: - Setup
    
    public init(cache: [String: Any] = [:]) {
        self.cache = cache
    }
    
    // MARK: - Boolean
    
    public func bool(forKey key: String) -> Bool {
        return cache[key] as? Bool ?? false
    }
    
    public func set(_ value: Bool, forKey key: String) {
        return cache[key] = value
    }
    
    // MARK: - Data
    
    public func data(forKey defaultName: String) -> Data? {
        return cache[defaultName] as? Data
    }
    
    public func set(_ value: Any?, forKey defaultName: String) {
        return cache[defaultName] = value
    }
}
