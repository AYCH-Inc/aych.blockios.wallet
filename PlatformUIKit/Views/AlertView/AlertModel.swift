//
//  AlertModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public struct AlertModel {
    public let image: UIImage?
    public let headline: String?
    public let body: String?
    public let actions: [AlertAction]
    public let dismissable: Bool
    public let style: AlertViewStyle
    
    public init(
        headline: String?,
        body: String?,
        actions: [AlertAction],
        image: UIImage? = nil,
        dismissable: Bool = true,
        style: AlertViewStyle = .default
    ) {
        self.headline = headline
        self.body = body
        self.actions = actions
        self.image = image
        self.dismissable = dismissable
        self.style = style
    }
}

public struct AlertAction {
    public let title: String
    public let style: AlertActionStyle
    public let metadata: ActionMetadata?
    
    public init(title: String, style: AlertActionStyle, metadata: ActionMetadata? = nil) {
        self.title = title
        self.style = style
        self.metadata = metadata
    }
}

public enum AlertActionStyle {
    /// Filled in `UIButton` with white text.
    /// It appears _above_ the `default` style button.
    case confirm
    /// `UIButton` with blue border and blue text.
    /// It appears _below_ the `confirm` style button.
    case `default`
    /// When the user taps outside of the view to dismiss it.
    case dismiss
}

public enum AlertViewStyle {
    case `default`
    case sheet
}
