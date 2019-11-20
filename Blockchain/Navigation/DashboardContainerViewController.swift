//
//  DashboardContainerViewController.swift
//  Blockchain
//
//  Created by AlexM on 2/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `DashboardContainerViewController` is likely how all future `UIViewControllers` will be
/// made when adding them to the `UITabBarController`. It conforms to `TabContainer`
/// which is a handy way of specifying what screen should be shown within a nested
/// `BaseNavigationController`. This is how we have screens within the `UITabBarController`
/// that can push and pop views onto their own navigation stack.
//class DashboardContainerViewController: BaseNavigationController, TabContainer {
//    
//    @IBInspectable var storyboardName: String?
//    
//    override open func awakeFromNib() {
//        super.awakeFromNib()
//        setup()
//    }
//    
//    @objc var dashboard: DashboardController? {
//        return viewControllers.first as? DashboardController
//    }
//}
