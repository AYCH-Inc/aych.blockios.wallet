//
//  SwitchTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

final class SwitchTableViewCell: UITableViewCell {
    
    // MARK: - Public Properites
    
    var presenter: SwitchCellPresenting! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else { return }
            switchView.viewModel = presenter.switchViewPresenting.viewModel
            presenter.labelContentPresenting.state
                .compactMap { $0 }
                .bind(to: rx.content)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Private Properties
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Private IBOutlets
    
    @IBOutlet fileprivate var switchView: SwitchView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .titleText
    }
}

// MARK: - Rx

extension Reactive where Base: SwitchTableViewCell {
    
    var content: Binder<LabelContentAsset.State.LabelItem.Presentation> {
        return Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.titleLabel.content = value.labelContent
            }
        }
    }
}

