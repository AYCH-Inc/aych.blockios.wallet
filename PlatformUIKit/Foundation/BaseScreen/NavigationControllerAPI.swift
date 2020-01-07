//
//  NavigationControllerAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 02/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol NavigationControllerAPI: class {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
}

extension UINavigationController: NavigationControllerAPI {}
