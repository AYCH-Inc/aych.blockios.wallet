//
//  BreadcrumbLogger.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Composition of all recording types
typealias Recording = MessageRecording & ErrorRecording & UIOperationRecording

/// Can be used to record any `String` message
protocol MessageRecording {
    func record(_ message: String)
    func record()
}

/// Can be used to record any `Error` message
protocol ErrorRecording {
    func error(_ error: Error)
    func error()
}

/// Records any illegal UI operation
protocol UIOperationRecording {
    func recordIllegalUIOperationIfNeeded()
}
