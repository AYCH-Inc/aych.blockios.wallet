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
        update(status: .withinLimit)
    }

    func update(status: LimitsButtonStatus) {
        switch status {
        case .withinLimit:
            rightButton.setImage(UIImage(named: "icon_limit_under"), for: .normal)
            drawButtonCircle(color: UIColor.tiersGray)
        case .overLimit:
            rightButton.setImage(UIImage(named: "icon_limit_over"), for: .normal)
            drawButtonCircle(color: UIColor.tiersRed)
        }
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
