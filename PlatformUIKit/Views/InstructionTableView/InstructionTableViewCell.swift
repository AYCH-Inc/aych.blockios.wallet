//
//  InstructionTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 11/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// This cell represents a single instruction in `InstructionTableView`
final class InstructionTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var instructionTextView: InteractableTextView!
    
    // MARK: - Injected
    
    var viewModel: InstructionCellViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            indexLabel.text = "\(viewModel.number)"
            instructionTextView.viewModel = viewModel.textViewModel
            instructionTextView.setupHeight()
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indexLabel.font = .mainBold(20)
        indexLabel.textColor = .titleText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}
