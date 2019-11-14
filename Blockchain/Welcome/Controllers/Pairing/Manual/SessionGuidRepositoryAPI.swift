//
//  SessionGuidRepositoryAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol GuidRepositoryAPI: class {
    var hasGuid: Bool { get }
    var guid: String? { set set }
}

extension GuidRepositoryAPI {
    var hasGuid: Bool {
        return guid != nil
    }
}
