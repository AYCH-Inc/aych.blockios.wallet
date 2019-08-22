//
//  SendRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 09/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: Move all send flows here, the VIPER stack should remain the same
// The only replaceable layer is the `asset: AssetType`.
// Move navigation logic here
// Move asset selection logic here
// Move entire tab item related logic here

/// Router for te send flow
@objc
final class SendRouter: NSObject {
    
    enum State {

        /// The initial screen
        case send
        
        /// Approval screen
        case approval
        
        /// Summary screen
        case summary
    }
    
    private let initialViewController: UIViewController
    private unowned let appCoordinator: AppCoordinator
    
    /// The presenters as per asset. This is the only resource that should be kept.
    private var presenters: [AssetType: SendPresenter] = [:]
    
    @objc
    init(using initialViewController: UIViewController, appCoordinator: AppCoordinator = .shared) {
        self.initialViewController = initialViewController
        self.appCoordinator = appCoordinator
    }
    
    // TODO: Extend logic to other assets.
    // TODO: Change legacy asset to asset once the tab controller is being refactored
    @objc
    func sendViewController(by legacyAsset: LegacyAssetType) -> SendViewController {
        let asset = AssetType.from(legacyAssetType: legacyAsset)
        if let presenter = presenters[asset] {
            return SendViewController(presenter: presenter)
        }
        
        let services = SendServiceContainer(asset: asset)
        let interactor = SendInteractor(services: services)
        let presenter = SendPresenter(router: self, interactor: interactor)
        presenters[asset] = presenter
        return SendViewController(presenter: presenter)
    }
    
    func presentQRScan(using builder: QRCodeScannerViewControllerBuilder<AddressQRCodeParser>) {
        guard let viewController = builder.with(dismissAnimated: true).build() else { return }
        initialViewController.present(viewController, animated: true, completion: nil)
    }
    
    func toggleSideMenu() {
        appCoordinator.toggleSideMenu()
    }
    
    // TODO: Remove this legacy function once tab controller
    @objc func presentQRCodeScan(using legacyAsset: LegacyAssetType) {
        let asset = AssetType.from(legacyAssetType: legacyAsset)
        presenters[asset]!.scanQRCode()
    }
}
