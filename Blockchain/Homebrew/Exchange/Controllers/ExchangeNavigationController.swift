//
//  ExchangeNavigationController.swift
//  Blockchain
//
//  Created by kevinwu on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeNavigationController: BCActionNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Default state
        showUnderLimit()
    }

    func showUnderLimit() {
        rightButton.setImage(UIImage(named: "icon_limit_under"), for: .normal)
        drawButtonCircle(color: UIColor.tiersGray)
    }

    func showOverLimit() {
        rightButton.setImage(UIImage(named: "icon_limit_over"), for: .normal)
        drawButtonCircle(color: UIColor.tiersRed)
    }

    private func drawButtonCircle(color: UIColor) {
        if let imageView = rightButton.imageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
            imageView.layer.borderWidth = 2.0
            imageView.layer.borderColor = color.cgColor
        }
    }
}
