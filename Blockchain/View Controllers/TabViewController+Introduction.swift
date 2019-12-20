//
//  TabViewController+Introduction.swift
//  Blockchain
//
//  Created by AlexM on 8/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit
import PlatformKit
import PlatformUIKit

extension TabViewController {
    
    @objc func setupIntroduction() {
        // TODO: RxSwift doesn't work in Obj-C, so `CardsDisposeBag` wraps Rx's bag.
        /// Upon migrating `CardsViewController` to `Swift`, strip and place `bag`.
        disposeBag = BridgedDisposeBag()
        
        introductionPresenter = WalletIntroductionPresenter(onboardingSettings: BlockchainSettings.Onboarding.shared, screen: .dashboard)
        introductionPresenter.introductionEvent.drive(onNext: { [weak self] event in
            guard let self = self else { return }
            self.execute(event: event)
        })
        .disposed(by: disposeBag.bag)
        
        introductionPresenter.start()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// We hide the `Pulse` when the view is not visible
        // and on `viewDidAppear` we resume the introduction. 
        PulseViewPresenter.shared.hide()
    }
    
    private func execute(event: WalletIntroductionPresentationEvent) {
        switch event {
        case .introductionComplete:
            break
        case .presentSheet(let type):
            let controller = IntroductionSheetViewController.make(with: type)
            controller.transitioningDelegate = sheetPresenter
            controller.modalPresentationStyle = .custom
            present(controller, animated: true, completion: nil)
        case .showPulse(let pulseViewModel):
            let location = pulseViewModel.location
            let position = location.position
            let screen = location.screen
            guard screen == .dashboard else { return }
            
            switch position {
            case .buySell:
                // Note: This should never happen as `buySell` should only be paired with the `.sideMenu` screen. 
                break
            case .home:
                PulseViewPresenter.shared.show(viewModel: .init(container: self.homePassthroughContainer, onSelection: pulseViewModel.action))
            case .send:
                PulseViewPresenter.shared.show(viewModel: .init(container: self.sendPassthroughContainer, onSelection: pulseViewModel.action))
            case .request:
                PulseViewPresenter.shared.show(viewModel: .init(container: self.requestPassthroughContainer, onSelection: pulseViewModel.action))
            case .swap:
                PulseViewPresenter.shared.show(viewModel: .init(container: self.swapPassthroughContainer, onSelection: pulseViewModel.action))
            }
        }
    }
    
}
