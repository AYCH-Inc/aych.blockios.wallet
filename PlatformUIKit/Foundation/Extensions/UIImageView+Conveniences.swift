//
//  UIImageView+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct ImageViewContent {
    let image: UIImage?
    let accessibility: Accessibility
    
    public init(image: UIImage?, accessibility: Accessibility = .none) {
        self.image = image
        self.accessibility = accessibility
    }
}

extension UIImageView {
    public var content: ImageViewContent {
        set {
            image = newValue.image
            accessibility = newValue.accessibility
        }
        get {
            return .init(
                image: image,
                accessibility: accessibility
            )
        }
    }
}

extension Reactive where Base: UIImageView {
    public var content: Binder<ImageViewContent> {
        return Binder(base) { imageView, content in
            imageView.content = content
        }
    }
}
