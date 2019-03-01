//
//  Drawer.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct BottomSheet {
    public let title: String
    public let dismissalTitle: String
    public let dismissable: Bool
    public let actions: [BottomSheetAction]
    
    public init(
        title: String,
        dismissalTitle: String,
        actions: [BottomSheetAction],
        dismissable: Bool = true
        ) {
        self.title = title
        self.dismissalTitle = dismissalTitle
        self.actions = actions
        self.dismissable = dismissable
    }
}

// TODO: Combine `AlertAction` with `BottomSheetAction`. They should be shared between
// `AlertView` and `BottomSheetView`. 
public struct BottomSheetAction {
    public typealias Action = () -> Void
    
    public let title: String
    public let metadata: ActionMetadata?
    
    public init(title: String, metadata: ActionMetadata? = nil) {
        self.title = title
        self.metadata = metadata
    }
}
