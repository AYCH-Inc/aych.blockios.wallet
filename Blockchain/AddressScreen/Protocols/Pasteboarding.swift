//
//  Clipboarding.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol Pasteboarding: class {
    var string: String? { get set }
}

extension UIPasteboard: Pasteboarding {}
