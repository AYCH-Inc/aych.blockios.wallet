//
//  BCActionNavigationController.swift
//  Blockchain
//
//  Created by kevinwu on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// BCNavigationController + buttons for custom actions.
class BCActionNavigationController: BCNavigationController {
    var rightButton: UIButton!
    var rightButtonTappedBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        rightButton = UIButton(frame: closeButton.frame)
        rightButton.imageEdgeInsets = closeButton.imageEdgeInsets
        rightButton.contentHorizontalAlignment = closeButton.contentHorizontalAlignment

        rightButton.backgroundColor = UIColor.clear

        view.addSubview(rightButton)
        rightButton.addTarget(self, action: #selector(self.rightButtonTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        rightButton.isHidden = self.viewControllers.count <= 1
        super.viewDidLayoutSubviews()
        closeButton.isHidden = self.viewControllers.count > 1
    }

    @objc func rightButtonTapped() {
        rightButtonTappedBlock?()
    }
}
