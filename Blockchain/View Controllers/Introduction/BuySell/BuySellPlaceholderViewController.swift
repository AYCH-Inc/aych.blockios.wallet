//
//  BuySellPlaceholderViewController.swift
//  Blockchain
//
//  Created by AlexM on 9/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit
import PlatformUIKit

/// NOTE: This class is not to be actually used by Buy-Sell.
/// This is only to mimic Buy-Sell during the introduction flow.
class BuySellPlaceholderViewController: UIViewController {
    
    @IBOutlet private var sellButton: UIButton!
    @IBOutlet private var buyButton: UIButton!
    @IBOutlet private var container: UIView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizationConstants.Onboarding.IntroductionSheet.BuySell.title
        sellButton.layer.cornerRadius = 4.0
        buyButton.layer.cornerRadius = 4.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// Not pretty but, doesn't really matter since this
        /// is just a placeholder screen.
        PulseViewPresenter.shared.show(viewModel: .init(container: container, onSelection: {
            // no-op
        }))
    }
    
    func presentIntroductionViewModel(_ viewModel: IntroductionSheetViewModel) {
        let controller = IntroductionSheetViewController.make(with: viewModel)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        present(controller, animated: true, completion: nil)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    private lazy var sheetPresenter: BottomSheetPresenting = {
        return BottomSheetPresenting()
    }()
}

extension BuySellPlaceholderViewController: NavigatableView {
    
    var leftNavControllerCTAType: NavigationCTAType {
        return .dismiss
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return .none
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        // no-op
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        dismiss(animated: true, completion: nil)
    }
}
