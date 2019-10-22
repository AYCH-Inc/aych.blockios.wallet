//
//  MnemonicTextView.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/11/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import RxCocoa

public class MnemonicTextView: UIView {
        
    // MARK: - Injected
    
    private var viewModel: MnemonicTextViewViewModel!
    
    // MARK: - UI Properties
    
    @IBOutlet private var textView: UITextView!
        
    private var keyboardInteractionController: KeyboardInteractionController!
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Internal API
    
    /// Should be called once upon instantiation
    func setup() {
        fromNib(named: MnemonicTextView.objectName)
        textView.textAlignment = .left
        textView.delegate = self
    }
    
    // MARK: - API
    
    /// Must be called by specialized subclasses
    public func setup(viewModel: MnemonicTextViewViewModel,
                      keyboardInteractionController: KeyboardInteractionController) {
        self.keyboardInteractionController = keyboardInteractionController
        self.viewModel = viewModel
        self.accessibility = viewModel.accessibility
        
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 4.0
        
        /// Use the given toolbar
        textView.inputAccessoryView = keyboardInteractionController.toolbar
        
        viewModel.borderColor
            .drive(textView.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        // Take only the first value emitted
        viewModel.attributedText
            .drive(textView.rx.attributedText)
            .disposed(by: disposeBag)
    }
}

// MARK: UITextViewDelegate

extension MnemonicTextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        let text = (textView.text ?? "").lowercased()
        viewModel.textViewEdited(with: text)
    }
}

