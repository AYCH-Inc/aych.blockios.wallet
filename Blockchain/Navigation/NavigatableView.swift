//
//  NavigatableView.swift
//  Blockchain
//
//  Created by Chris Arriola on 1/29/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import SafariServices

enum NavigationCTA {
    case dismiss
    case help
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            return #imageLiteral(resourceName: "close.png")
        case .help:
            return #imageLiteral(resourceName: "icon_help.pdf")
        case .none:
            return nil
        }
    }

    var visibility: Visibility {
        switch self {
        case .dismiss:
            return .visible
        case .help:
            return .visible
        case .none:
            return .hidden
        }
    }
}

/// Protocol definition for a view that can be navigated to. Typically implemented by
/// a UIViewController for easily adding a CTA in the top right corner.
protocol NavigatableView {
    var ctaTintColor: UIColor? { get }

    func navControllerCTAType() -> NavigationCTA

    func navControllerRightBarButtonTapped(_ navController: UINavigationController)
}

extension NavigatableView where Self: UIViewController {
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

    func presentNeedSomeHelpAlert() {
        let confirm = AlertAction(title: LocalizationConstants.KYC.readNow, style: .confirm)
        let cancel = AlertAction(title: LocalizationConstants.KYC.contactSupport, style: .default)
        let model = AlertModel(
            headline: LocalizationConstants.KYC.needSomeHelp,
            body: LocalizationConstants.KYC.helpGuides,
            actions: [confirm, cancel]
        )
        let alert = AlertView.make(with: model) { [weak self] action in
            guard let this = self else { return }
            guard let endpoint = URL(string: "https://blockchain.zendesk.com/") else { return }
            switch action.style {
            case .confirm:
                guard let url = URL.endpoint(
                    endpoint,
                    pathComponents: ["hc", "en-us", "categories", "360001135512-Identity-Verification"],
                    queryParameters: nil
                    ) else { return }
                let controller = SFSafariViewController(url: url)
                this.present(controller, animated: true, completion: nil)
            case .default:
                guard let url = URL.endpoint(
                    endpoint,
                    pathComponents: ["hc", "en-us", "requests", "new"],
                    queryParameters: ["ticket_form_id" : "360000186571"]
                    ) else { return }
                let controller = SFSafariViewController(url: url)
                this.present(controller, animated: true, completion: nil)
            }
        }
        alert.show()
    }
}
