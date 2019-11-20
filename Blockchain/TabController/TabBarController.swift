//
//  TabBarController.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Exposed
    
    var drawerGestureView: UIView!
    
    // MARK: - Injected
    
    private let presenter: TabBarPresenter
    
    /// Drawer root
    private unowned let menu: ECSlidingViewController
    
    // MARK: - Setup
    
    init(presenter: TabBarPresenter, in menu: ECSlidingViewController) {
        self.menu = menu
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let transactionsVC = TransactionsContainerViewController()
        let swapVC = ExchangeContainerViewController.makeFromStoryboard()
        let dashboardVC = DashboardViewController()
        let sendVC = SendContainerViewController()
        let requestVC = RequestContainerViewController()
        let viewControllers = [transactionsVC, swapVC, dashboardVC, sendVC, requestVC]
            .map { NavigationController(rootViewController: $0) }
        viewControllers
            .enumerated()
            .forEach { item in
                item.element.tabBarItem = UITabBarItem(with: presenter.itemContentArray[item.offset])
            }
        self.viewControllers = viewControllers
        
        setupDrawerGesture()
    }
    
    private func setupDrawerGesture() {
        drawerGestureView = UIView()
        view.addSubview(drawerGestureView)
        drawerGestureView.layoutToSuperview(.vertical)
        NSLayoutConstraint.activate([
            drawerGestureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawerGestureView.heightAnchor.constraint(equalToConstant: 20)
        ])
        drawerGestureView.addGestureRecognizer(menu.panGesture)
    }
}

// MARK: - UITabBarControllerDelegate

// TODO: Handle transitions
extension TabBarController: UITabBarControllerDelegate {}
