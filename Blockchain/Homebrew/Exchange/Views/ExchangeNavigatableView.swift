//
//  ExchangeNavigatableView.swift
//  Blockchain
//
//  Created by Chris Arriola on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import SafariServices

/// Protocol definition for a view that can be navigated to. Typically implemented by
/// a UIViewController for easily adding a CTA in the top right corner.
protocol ExchangeNavigatableView {
    var ctaTintColor: UIColor? { get }

    func navControllerCTAType() -> NavigationCTA

    func navControllerRightBarButtonTapped(_ navController: UINavigationController)
}

extension ExchangeNavigatableView where Self: UIViewController {
    var ctaTintColor: UIColor? {
        return nil
    }

    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        switch navControllerCTAType() {
        case .none:
            break
        case .dismiss:
            navController.dismiss(animated: true)
        case .help:
            presentNeedSomeHelpAlert()
        }
    }

    /// Presents a help alert that has a CTA for contacting support and viewing the user's
    /// swap limits. Override this method or navControllerRightBarButtonTapped to change the
    /// behavior
    func presentNeedSomeHelpAlert() {
        let contactSupport = AlertAction(title: LocalizationConstants.KYC.contactSupport, style: .confirm)
        let viewLimits = AlertAction(title: LocalizationConstants.Swap.viewMySwapLimit, style: .default)
        let model = AlertModel(
            headline: LocalizationConstants.KYC.needSomeHelp,
            body: LocalizationConstants.Swap.helpDescription,
            actions: [contactSupport, viewLimits]
        )
        let alert = AlertView.make(with: model) { [weak self] action in
            guard let this = self else { return }
            guard let endpoint = URL(string: "https://blockchain.zendesk.com/") else { return }
            switch action.style {
            case .confirm:
                guard let url = URL.endpoint(
                    endpoint,
                    pathComponents: ["hc", "en-us", "requests", "new"],
                    queryParameters: ["ticket_form_id" : "360000180551"]
                    ) else { return }
                let controller = SFSafariViewController(url: url)
                this.present(controller, animated: true, completion: nil)
            case .default:
                _ = KYCTiersViewController.routeToTiers(
                    fromViewController: this
                )
            }
        }
        alert.show()
    }
}
