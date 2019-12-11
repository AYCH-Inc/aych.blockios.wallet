//
//  TopMostViewControllerProviding.swift
//  PlatformKit
//
//  Created by Daniel Huri on 27/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// A provider protocol for top most view controller
public protocol TopMostViewControllerProviding: class {
    var topMostViewController: UIViewController? { get }
}

// MARK: - UIApplication

extension UIApplication: TopMostViewControllerProviding {
    public var topMostViewController: UIViewController? {
        return keyWindow?.topMostViewController
    }
}

// MARK: - UIWindow

extension UIWindow: TopMostViewControllerProviding {
    public var topMostViewController: UIViewController? {
        return rootViewController?.topMostViewController
    }
}

// MARK: - UIViewController

extension UIViewController: TopMostViewControllerProviding {

    /// Returns the top-most visibly presented UIViewController in this UIViewController's hierarchy
    @objc
    public var topMostViewController: UIViewController? {
        return presentedViewController?.topMostViewController ?? self
    }
}

// MARK: - UINavigationController

extension UINavigationController {
    override public var topMostViewController: UIViewController? {
        return self
    }
}

// MARK: - UIAlertController

extension UIAlertController {

    /// Overridden so that UIAlertControllers will never show up as the `topMostViewController`.
    override public var topMostViewController: UIViewController? {
        return presentedViewController?.topMostViewController
    }
}
