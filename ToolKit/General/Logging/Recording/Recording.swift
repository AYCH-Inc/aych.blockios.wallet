//
//  BreadcrumbLogger.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Useful for injecting recorders
public protocol Recordable {
    func use(recorder: Recording)
}

/// Composition of all recording types
public typealias Recording = MessageRecording & ErrorRecording & UIOperationRecording

/// Can be used to record any `String` message
public protocol MessageRecording {
    func record(_ message: String)
    func record()
}

/// Can be used to record any `Error` message
public protocol ErrorRecording {
    func error(_ error: Error)
    func error(_ errorMessage: String)
    func error()
}

/// Records any illegal UI operation
public protocol UIOperationRecording {
    func recordIllegalUIOperationIfNeeded()
}
