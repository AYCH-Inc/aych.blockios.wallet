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
        rightButtonTappedBlock = {

        }
        rightButton.setImage(UIImage(named: "icon_limit_under"), for: .normal)
        if let imageView = rightButton.imageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
            imageView.layer.borderWidth = 2.0
            imageView.layer.borderColor = UIColor.circleGray.cgColor
        }
    }
}
