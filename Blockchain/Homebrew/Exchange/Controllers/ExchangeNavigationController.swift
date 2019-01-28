//
//  ExchangeNavigationController.swift
//  Blockchain
//
//  Created by kevinwu on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeNavigationController: BCActionNavigationController {
    
    var status: LimitsButtonStatus = .withinLimit {
        didSet {
            guard rightButton != nil else { return }
            switch status {
            case .withinLimit:
                rightButton.setImage(UIImage(named: "icon_limit_under"), for: .normal)
                drawButtonCircle(color: .tiersGray)
            case .overLimit:
                rightButton.setImage(UIImage(named: "icon_limit_over"), for: .normal)
                drawButtonCircle(color: .tiersRed)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Default state
        status = .withinLimit
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
