//
//  LoadingView.swift
//  PlatformUIKit
//
//  Created by kevinwu on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// Protocol for a view that performs an async function.
public protocol LoadingView: class {
    func showLoadingIndicator()

    func hideLoadingIndicator()

    func showErrorMessage(_ message: String)
}
