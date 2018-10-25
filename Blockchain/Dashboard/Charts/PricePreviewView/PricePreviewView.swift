//
//  PricePreviewView.swift
//  Blockchain
//
//  Created by Maurice A. on 10/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class PricePreviewView: UIView {

    // MARK: - Properties

    var seeChartsButtonHandler: (() -> Void)?

    var currencyTitle: String {
        get {
            return currencyTitleLabel.text ?? ""
        }
        set {
            currencyTitleLabel.text = newValue
        }
    }

    var price: String {
        get {
            return priceLabel.text ?? ""
        }
        set {
            priceLabel.text = newValue
        }
    }

    // MARK: - IBOutlets

    @IBOutlet private var currencyTitleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!

    // MARK: - IBActions

    @IBAction private func seeCharts(_ sender: UIButton) {
        seeChartsButtonHandler?()
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 4
    }
}
