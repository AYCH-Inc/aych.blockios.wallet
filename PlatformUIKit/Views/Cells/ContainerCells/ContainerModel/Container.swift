//
//  Container.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// ContainerDelegate provides a consistent way to bubble up
/// nested cell taps.
public protocol ContainerDelegate: class {
    func container(_ container: UICollectionViewCell, didSelectItemAt indexPath: IndexPath)
}

protocol Container {
    var delegate: ContainerDelegate? { get set }
}
