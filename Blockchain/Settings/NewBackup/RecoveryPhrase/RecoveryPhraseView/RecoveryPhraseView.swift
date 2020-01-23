//
//  RecoveryPhraseView.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformUIKit

final class RecoveryPhraseView: UIView {
    
    // MARK: - Public Properties
    
    var viewModel: RecoveryPhraseViewModel! {
        didSet {
            viewModel.words
                .bind(to: rx.mnemonicContent)
                .disposed(by: disposeBag)
            
            clipboardButtonView.viewModel = viewModel.copyButtonViewModel
        }
    }
    
    // MARK: Private IBOutlets (UILabel)
    
    @IBOutlet private var firstLabel: UILabel!
    @IBOutlet private var secondLabel: UILabel!
    @IBOutlet private var thirdLabel: UILabel!
    @IBOutlet private var fourthLabel: UILabel!
    @IBOutlet private var fifthLabel: UILabel!
    @IBOutlet private var sixthLabel: UILabel!
    @IBOutlet private var seventhLabel: UILabel!
    @IBOutlet private var eigthLabel: UILabel!
    @IBOutlet private var ninthLabel: UILabel!
    @IBOutlet private var tenthLabel: UILabel!
    @IBOutlet private var eleventhLabel: UILabel!
    @IBOutlet private var twelfthLabel: UILabel!
    
    // MARK: - Private IBOutlets (Other)
    
    @IBOutlet private var numberedLabels: [UILabel]!
    @IBOutlet private var clipboardButtonView: ButtonView!
    
    // MARK: - Private Properties
    
    fileprivate var labels: [UILabel] {
        return [
            firstLabel,
            secondLabel,
            thirdLabel,
            fourthLabel,
            fifthLabel,
            sixthLabel,
            seventhLabel,
            eigthLabel,
            ninthLabel,
            tenthLabel,
            eleventhLabel,
            twelfthLabel
        ]
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        fromNib()
        clipsToBounds = true
        numberedLabels.forEach { $0.textColor = .mutedText }
        layer.cornerRadius = 8.0
        backgroundColor = .background
    }
}

fileprivate extension Reactive where Base: RecoveryPhraseView {
    var mnemonicContent: Binder<([LabelContent])> {
        return Binder(base) { view, payload in
            payload.enumerated().forEach { value in
                view.labels[value.0].content = value.1
            }
        }
    }
}
