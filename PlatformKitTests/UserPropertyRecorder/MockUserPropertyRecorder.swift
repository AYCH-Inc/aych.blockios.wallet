//
//  MockUserPropertyRecorder.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
@testable import PlatformKit

final class MockUserPropertyRecorder: UserPropertyRecording {
    
    private(set) var id = ""
    private(set) var hashed: Set<HashedUserProperty> = []
    private(set) var standard: Set<StandardUserProperty> = []
    
    func record(id: String) {
        self.id = id
    }
    
    func record(_ property: StandardUserProperty) {
        standard.insert(property)
    }

    func record(_ property: HashedUserProperty) {
        hashed.insert(property)
    }
}
