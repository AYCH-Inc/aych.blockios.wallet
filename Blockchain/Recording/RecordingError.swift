//
//  RecordingError.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Any recorded error should be added here
enum RecordingError: Error {
    
    /// Breadcrumb (no information
    case breadcrumb
    
    /// Changing the UI on a background thread
    case changingUIOnBackgroundThread
}
