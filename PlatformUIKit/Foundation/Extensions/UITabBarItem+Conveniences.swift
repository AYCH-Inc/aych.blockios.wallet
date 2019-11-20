//
//  UITabBarItem+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct TabItemContent {
    let title: String
    let image: String
    let selectedImage: String
    let accessibility: Accessibility
    
    public init(title: String,
                image: String,
                selectedImage: String,
                accessibility: Accessibility) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.accessibility = accessibility
    }
}

extension UITabBarItem {
    public convenience init(with content: TabItemContent) {
        self.init(
            title: content.title,
            image: UIImage(named: content.image),
            selectedImage: UIImage(named: content.selectedImage)
        )
        accessibilityIdentifier = content.accessibility.id.rawValue
    }
}
