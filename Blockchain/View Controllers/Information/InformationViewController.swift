//
//  InformationViewController.swift
//  Blockchain
//
//  Created by kevinwu on 11/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class InformationViewController: UIViewController {
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var button: UIButton!

    private var bodyText: String?
    private var buttonTitle: String?
    private var buttonAction: ((Any) -> ())?

    // MARK: Factory

    @objc class func make(
        with bodyText: String,
        buttonTitle: String,
        buttonAction: ((Any) -> ())?
    ) -> InformationViewController {
        let controller = InformationViewController.makeFromStoryboard()
        controller.bodyText = bodyText
        controller.buttonTitle = buttonTitle
        controller.buttonAction = buttonAction
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = bodyText
        button.setTitle(buttonTitle, for: .normal)
        button.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
    }

    @IBAction private func buttonTapped(_ sender: Any) {
        guard let action = buttonAction else { return }
        action(sender)
    }
}
