//
//  AirdropRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

protocol AirdropRouterAPI: class {
    
    /// Presents airdrop status screen for raw value of `AirdropCampaigns.Campaign.Name`.
    func presentAirdropStatusScreen(for campaignName: String,
                                    presentationType: PresentationType)
    
    /// Presents airdrop status screen for `AirdropCampaigns.Campaign.Name`.
    func presentAirdropStatusScreen(for campaignName: AirdropCampaigns.Campaign.Name,
                                    presentationType: PresentationType)
    
    /// Presents airdrop center screen (collection of airdrop campaigns)
    func presentAirdropCenterScreen()
}

/// A router responsible for airdrop center and detail presentation
final class AirdropRouter: AirdropRouterAPI {
        
    private weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    private weak var navigationControllerAPI: NavigationControllerAPI?
    
    init(topMostViewControllerProvider: TopMostViewControllerProviding) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }
    
    func presentAirdropStatusScreen(for campaignName: String,
                                    presentationType: PresentationType) {
        guard let campaignName = AirdropCampaigns.Campaign.Name(rawValue: campaignName) else {
            return
        }
        presentAirdropStatusScreen(for: campaignName, presentationType: presentationType)
    }
    
    func presentAirdropStatusScreen(for campaignName: AirdropCampaigns.Campaign.Name,
                                    presentationType: PresentationType) {
        
        // Prepare the stack
        
        let interactor = AirdropStatusScreenInteractor(campaignName: campaignName)
        let presenter = AirdropStatusScreenPresenter(
            presentationType:
            presentationType, interactor: interactor
        )
        let viewController = AirdropStatusScreenViewController(presenter: presenter)
        
        // Present the screen
        
        let presentModal = { [unowned self] (parent: ViewControllerAPI) in
            let navigationController = UINavigationController(rootViewController: viewController)
            parent.present(navigationController, animated: true, completion: nil)
            self.navigationControllerAPI = navigationController
        }
        
        switch presentationType {
        case .modal(from: let parentViewController):
            presentModal(parentViewController)
        case .navigation(from: let originViewController):
            originViewController.navigationControllerAPI?.pushViewController(viewController, animated: true)
        case .navigationFromCurrent:
            navigationControllerAPI?.pushViewController(viewController, animated: true)
        case .modalOverTopMost:
            if let parentViewController = topMostViewControllerProvider.topMostViewController {
                presentModal(parentViewController)
            }
        }
    }
        
    func presentAirdropCenterScreen() {
        guard let parentViewController = topMostViewControllerProvider.topMostViewController else {
            return
        }
        
        // Prepare the stack
        
        let presenter = AirdropCenterScreenPresenter(router: self)
        let viewController = AirdropCenterScreenViewController(presenter: presenter)
        
        // Present the screen
        
        let navigationController = UINavigationController(rootViewController: viewController)
        parentViewController.present(navigationController, animated: true, completion: nil)
        navigationControllerAPI = navigationController
    }
}
