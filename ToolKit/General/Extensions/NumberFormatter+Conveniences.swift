//
//  NumberFormatter+Conveniences.swift
//  ToolKit
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public extension NumberFormatter {
    static let ordinal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
}
