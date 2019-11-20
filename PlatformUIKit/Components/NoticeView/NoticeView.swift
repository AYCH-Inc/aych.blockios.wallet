//
//  NoticeView.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public final class NoticeView: UIView {

    // MARK: - IBOutlet Properties
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!
    
    // MARK: - Injected
    
    public var viewModel: NoticeViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            imageView.image = UIImage(named: viewModel.image)
            label.content = viewModel.labelContent
        }
    }
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
        
    private func setup() {
        fromNib()
    }
}
