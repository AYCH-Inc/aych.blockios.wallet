//
//  MultiActionTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class MultiActionTableViewCell: UITableViewCell {
    
    var presenter: MultiActionViewPresenting! {
        didSet {
            multiActionView.presenter = presenter
        }
    }
    
    @IBOutlet private var multiActionView: MultiActionView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
    
    private func setup() {
        
    }
}
