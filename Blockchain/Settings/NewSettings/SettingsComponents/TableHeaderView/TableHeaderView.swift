//
//  SettingsTableHeaderView.swift
//  Blockchain
//
//  Created by AlexM on 12/13/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

final class TableHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Private Static Properties
    
    private static let verticalPadding: CGFloat = 32.0
    private static let horizontalPadding: CGFloat = 8.0
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    var viewModel: TableHeaderViewModel! {
        didSet {
            
            titleLabel.font = viewModel.font
            
            // Bind label text
            viewModel.text
                .drive(titleLabel.rx.text)
                .disposed(by: disposeBag)
            
            // Bind label text color
            viewModel.contentColor
                .drive(titleLabel.rx.textColor)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
}
