//
//  Rx+UISegmentedControl.swift
//  PlatformUIKit
//
//  Created by AlexM on 11/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

extension Reactive where Base: UISegmentedControl {
    public var backgroundImageFillColor: Binder<UIColor?> {
        return Binder(base) { segmentedControl, fillColor in
            guard let color = fillColor else { return }
            guard let backgroundImage = UIImage.image(color: color, size: segmentedControl.frame.size) else { return }
            segmentedControl.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        }
    }
    
    public var selectedTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(base) { segmentedControl, textAttributes in
            segmentedControl.setTitleTextAttributes(textAttributes, for: .selected)
        }
    }
    
    public var normalTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(base) { segmentedControl, textAttributes in
            segmentedControl.setTitleTextAttributes(textAttributes, for: .normal)
        }
    }
    
    public var dividerColor: Binder<UIColor?> {
        return Binder(base) { segmentedControl, dividerColor in
            guard let color = dividerColor else { return }
            let image = UIImage.image(color: color, size: .init(width: 0.5, height: 1.0))
            segmentedControl.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        }
    }
}
