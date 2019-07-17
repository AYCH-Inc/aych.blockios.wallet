//
//  BaseNavigationController.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

enum NavigationCTAType {
    case qrCode
    case dismiss
    case back
    case menu
    case help
    case error
    case activityIndicator
    case none
}

fileprivate extension NavigationCTAType {
    var image: UIImage? {
        switch self {
        case .qrCode:
            return #imageLiteral(resourceName: "qrscanner.png").withRenderingMode(.alwaysTemplate)
        case .dismiss:
            return #imageLiteral(resourceName: "close.png").withRenderingMode(.alwaysTemplate)
        case .menu:
            return #imageLiteral(resourceName: "menu.png").withRenderingMode(.alwaysTemplate)
        case .help:
            return #imageLiteral(resourceName: "icon_menu.png").withRenderingMode(.alwaysTemplate)
        case .back:
            return #imageLiteral(resourceName: "back_chevron_icon.png").withRenderingMode(.alwaysTemplate)
        case .error:
            return #imageLiteral(resourceName: "error-triangle.pdf")
        case .activityIndicator:
            return nil
        case .none:
            return nil
        }
        
    }
}

enum NavigationBarDisplayMode {
    case light
    case dark
}

extension NavigationBarDisplayMode {
    var tintColor: UIColor {
        switch self {
        case .dark:
            return .brandPrimary
        case .light:
            return .white
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return .brandPrimary
        }
    }
}

protocol NavigatableView: class {
    
    var rightCTATintColor: UIColor { get }
    var leftCTATintColor: UIColor { get }
    
    var navigationDisplayMode: NavigationBarDisplayMode { get }
    
    var rightNavControllerCTAType: NavigationCTAType { get }
    var leftNavControllerCTAType: NavigationCTAType { get }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController)
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController)
}

extension NavigatableView where Self: UIViewController {
    var leftCTATintColor: UIColor {
        return .white
    }
    
    var rightCTATintColor: UIColor {
        return .white
    }
    
    var leftNavControllerCTAType: NavigationCTAType {
        return .menu
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return .qrCode
    }
    
    var navigationDisplayMode: NavigationBarDisplayMode {
        return .dark
    }
}

/// `BaseNavigationController` is meant to be a replacement of `BCNavigationController`
/// It relies on `NavigatableView` to properly layout it's `UIBarButtonItems` as well
/// as style itself. There is no default behavior should the current `UIViewController`
/// not conform to `NavigatableView`. This is because the behaviors across all our different
/// screens are pretty different. 
@objc class BaseNavigationController: UINavigationController {
    
    private var leftBarButtonItem: UIBarButtonItem!
    private var rightBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // TODO: This is not efficient as `viewWillLayoutSubviews` can get called unexpectedly on on view changes
        setupNavigationController()
    }
    
    fileprivate func setupNavigationController() {
        guard let controller = viewControllers.last else { return }
        guard let navigatableView = controller as? NavigatableView else {
            return
        }
        
        if navigatableView.rightNavControllerCTAType == .activityIndicator {
            let activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.startAnimating()
            controller.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        } else {
            controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: navigatableView.rightNavControllerCTAType.image,
                style: .plain,
                target: self,
                action: #selector(rightBarButtonTapped)
            )
        }
        
        if navigatableView.leftNavControllerCTAType == .activityIndicator {
            assertionFailure("You should put the activity indicator in the right CTA.")
        } else {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: navigatableView.leftNavControllerCTAType.image,
                style: .plain,
                target: self,
                action: #selector(leftBarButtonTapped)
            )
        }
        
        controller.navigationItem.rightBarButtonItem?.tintColor = navigatableView.rightCTATintColor
        controller.navigationItem.leftBarButtonItem?.tintColor = navigatableView.leftCTATintColor
        navigationBar.backgroundColor = navigatableView.navigationDisplayMode.tintColor
        navigationBar.barTintColor = navigatableView.navigationDisplayMode.tintColor
        navigationBar.titleTextAttributes = [
            .font: BaseNavigationController.titleFont(),
            .foregroundColor: navigatableView.navigationDisplayMode.textColor
        ]
    }
    
    @objc func update() {
        setupNavigationController()
    }
    
    @objc fileprivate func rightBarButtonTapped() {
        guard let navigatableView = visibleViewController as? NavigatableView else {
            return
        }
        guard navigatableView.rightNavControllerCTAType != .activityIndicator else { return }
        navigatableView.navControllerRightBarButtonTapped(self)
    }
    
    @objc fileprivate func leftBarButtonTapped() {
        guard let navigatableView = visibleViewController as? NavigatableView else {
            return
        }
        navigatableView.navControllerLeftBarButtonTapped(self)
    }
    
    fileprivate static func titleFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(23.0))
        return font.result
    }
}
