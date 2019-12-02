//
//  Atomic.swift
//  PlatformKit
//
//  Created by Jack on 18/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// A wrapper for atomic access to the wrapped value
// Uses a serial `DispatchQueue` for safety
public final class Atomic<Value> {
    
    // MARK: - Public properties
    
    /// Atomic access to the wrapped value
    public var value: Value {
        return queue.sync { self._value }
    }
    
    // MARK: - Private properties
    
    private var _value: Value
    
    /// Allow concurrent reads to improve performance:
    /// https://basememara.com/creating-thread-safe-generic-values-in-swift/
    private let queue = DispatchQueue(label: "Atomic read/write queue", attributes: .concurrent)
    
    // MARK: - Init
    
    public init(_ value: Value) {
        self._value = value
    }
    
    // MARK: - Public methods
    
    /// Atomically mutates the wrapped value
    ///
    /// The `transform` closure should not perform any slow computation as it it blocks the current thread
    /// For more information see: https://github.com/objcio/S01E42-thread-safety-reactive-programming-5/commit/2c8b4c60e2154776b575ce7641b6e23e4e8be12d
    ///
    /// - Parameter transform: transforms the wrapped value passing a `inout` parameter to allow mutation
    public func mutate(_ transform: (inout Value) -> ()) {
        queue.sync(flags: .barrier) {
            transform(&self._value)
        }
    }
}
