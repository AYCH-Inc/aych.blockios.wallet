//
//  BottomSheetViewController.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public final class IntroductionSheetViewController: UIViewController {
    
    private typealias AccessibilityIdentifiers = Accessibility.Identifier.IntroductionSheet
    
    // MARK: Private Properties
    
    private let bag: DisposeBag = DisposeBag()
    private var viewModel: IntroductionSheetViewModel!
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var thumbnail: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var button: UIButton!
    
    // TICKET: IOS-2520 - Move Storyboardable Protocol to PlatformUIKit
    public static func make(with viewModel: IntroductionSheetViewModel) -> IntroductionSheetViewController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: String(describing: self), bundle: bundle)
        guard let controller = storyboard.instantiateInitialViewController() as? IntroductionSheetViewController else {
            fatalError("\(String(describing: self)) not found.")
        }
        controller.viewModel = viewModel
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        button.setTitle(viewModel.buttonTitle, for: .normal)
        button.layer.cornerRadius = 4.0
        button.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.onSelection()
            self.dismiss(animated: true, completion: nil)
        }
        .disposed(by: bag)
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.description
        thumbnail.image = viewModel.thumbnail
        
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        button.accessibility = .init(id: .value(AccessibilityIdentifiers.doneButton))
        titleLabel.accessibility = .init(id: .value(AccessibilityIdentifiers.titleLabel))
        subtitleLabel.accessibility = .init(id: .value(AccessibilityIdentifiers.subtitleLabel))
    }
}
