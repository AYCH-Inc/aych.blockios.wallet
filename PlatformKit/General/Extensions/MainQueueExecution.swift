//
//  MainQueueExecution.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 11/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Container for executions
public struct Execution {
    
    /// Main queue execution
    public struct MainQueue {
        
        /// A work item to be executed
        public typealias WorkItem = () -> Void
        
        /// Executes a given action on the main queue efficiently firstly by making sure the current queue is the main one
        public static func dispatch(_ action: @escaping WorkItem) {
            if Thread.isMainThread {
                action()
            } else {
                DispatchQueue.main.async(execute: action)
            }
        }
    }
}
