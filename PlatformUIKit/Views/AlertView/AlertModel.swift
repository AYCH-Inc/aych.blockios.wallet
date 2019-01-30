//
//  AlertModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct AlertModel {
    public let headline: String?
    public let body: String?
    public let actions: [AlertAction]
    
    public init(headline: String?, body: String?, actions: [AlertAction]) {
        self.headline = headline
        self.body = body
        self.actions = actions
    }
}

public struct AlertAction {
    public let title: String
    public let style: AlertActionStyle
    
    public init(title: String, style: AlertActionStyle) {
        self.title = title
        self.style = style
    }
}

public enum AlertActionStyle {
    /// Filled in `UIButton` with white text.
    /// It appears _above_ the `default` style button.
    case confirm
    /// `UIButton` with blue border and blue text.
    /// It appears _below_ the `confirm` style button.
    case `default`
}
