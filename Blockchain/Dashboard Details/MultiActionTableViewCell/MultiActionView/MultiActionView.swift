//
//  MultiActionView.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformUIKit

final class MultiActionView: UIView {
    
    // MARK: - Injected
    
    var presenter: MultiActionViewPresenting! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else {
                return
            }
            segmentedView.viewModel = presenter.segmentedViewModel
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var segmentedView: SegmentedView!
    
    // MARK: - Private Properties
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        fromNib()
    }
}
