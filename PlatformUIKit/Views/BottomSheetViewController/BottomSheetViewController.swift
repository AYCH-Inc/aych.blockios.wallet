//
//  BottomSheetViewController.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class BottomSheetViewController: UIViewController {
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var button: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 4.0
    }
}
