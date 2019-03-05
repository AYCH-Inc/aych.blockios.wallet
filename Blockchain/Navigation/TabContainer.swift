//
//  TabContainer.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `TabContainer` is used in `DashboardContainerViewController` and is how
/// future (new) `UIViewControllers` will be added to the `UITabBarController`.
/// You add a runtime attribute called `storyboardName`, set the
/// value to whatever `UIStoryboard` you want to use and
/// it sets the `rootViewController` of the `UINavigationController`
/// as that initial storyboard.
protocol TabContainer {
    var storyboardName: String? { get set }
    func setup()
}

extension TabContainer where Self: UINavigationController {
    func setup() {
        guard let name = storyboardName else {
            assertionFailure("StoryboardName must be set in IB.")
            return
        }
        if let rootViewController = UIStoryboard(name: name, bundle: Bundle(for: type(of: self))).instantiateInitialViewController() {
            self.setViewControllers([rootViewController], animated: false)
        }
    }
}
