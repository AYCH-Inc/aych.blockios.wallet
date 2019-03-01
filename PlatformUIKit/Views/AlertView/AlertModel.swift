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
    public let imageHeight: CGFloat?
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
        imageHeight: CGFloat? = nil,
        dismissable: Bool = true,
        style: AlertViewStyle = .default
    ) {
        self.headline = headline
        self.body = body
        self.actions = actions
        self.image = image
        self.imageHeight = imageHeight
        self.dismissable = dismissable
        self.style = style
    }
}

public protocol AlertActionPayload { }

public struct AlertAction {
    public let title: String
    public let style: AlertActionStyle
    public let metadata: Metadata?
    
    public init(title: String, style: AlertActionStyle, metadata: AlertAction.Metadata? = nil) {
        self.title = title
        self.style = style
        self.metadata = metadata
    }
    
    /// This may be renamed but the idea here is that where `AlertActions` are built
    /// you can define different things that should happen when the action is selected like
    /// presenting a URL, executing a block, or receiving any `AlertActionPayload` if you
    /// need some custom behavior.
    public enum Metadata {
        case url(URL)
        case block(() -> Void)
        case pop
        case dismiss
        case payload(AlertActionPayload)
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

public enum AlertViewStyle {
    case `default`
    case sheet
}
