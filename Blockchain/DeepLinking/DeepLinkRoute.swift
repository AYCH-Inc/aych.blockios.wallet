//
//  DeepLinkRoute.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum DeepLinkRoute: String, CaseIterable {
    case xlmAirdop
    case kyc
    case kycVerifyEmail
    case kycDocumentResubmission
    case pitVerifyEmail
    case pitLinking
}

extension DeepLinkRoute {

    static func route(from url: String,
                      supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases) -> DeepLinkRoute? {
        guard let lastPathWithProperties = url.components(separatedBy: "/").last else {
            return nil
        }

        let pathToParametersComponents = lastPathWithProperties.components(separatedBy: "?")
        guard let path = pathToParametersComponents.first else {
            return nil
        }

        // Get parameters
        var parameters = [String: String]()
        let parameterPairs = pathToParametersComponents.last?.components(separatedBy: "&")
        parameterPairs?.forEach { pair in
            let paramComponents = pair.components(separatedBy: "=")
            guard let key = paramComponents.first,
                let value = paramComponents.last?.removingPercentEncoding else {
                return
            }
            parameters[key] = value
        }

        return DeepLinkRoute.route(path: path,
                                   parameters: parameters,
                                   supportedRoutes: supportedRoutes)
    }

    private static func route(path: String,
                              parameters: [String: String]?,
                              supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases) -> DeepLinkRoute? {
        return supportedRoutes.first { route -> Bool in
            if route.supportedPath == path {
                if let key = route.requiredKeyParam,
                    let value = route.requiredValueParam,
                    let routeParameters = parameters {
                    
                    if let optionalKey = route.optionalKeyParameter,
                        let value = routeParameters[optionalKey],
                        let context = ContextParameter(rawValue: value) {
                        return route == .pitVerifyEmail && context == .pitSignup
                    } else {
                        return routeParameters[key] == value
                    }
                }
                return true
            }
            return false
        }
    }

    private var supportedPath: String {
        switch self {
        case .xlmAirdop:
            return "referral"
        case .kycVerifyEmail,
             .kycDocumentResubmission,
             .pitVerifyEmail:
            return "login"
        case .kyc:
            return "kyc"
        case .pitLinking:
            return "link-account"
        }
    }

    private var requiredKeyParam: String? {
        switch self {
        case .xlmAirdop:
            return "campaign"
        case .kyc,
             .kycVerifyEmail,
             .kycDocumentResubmission,
             .pitVerifyEmail:
            return "deep_link_path"
        case .pitLinking:
            return nil
        }
    }

    private var requiredValueParam: String? {
        switch self {
        case .xlmAirdop:
            return "sunriver"
        case .kycVerifyEmail,
             .pitVerifyEmail:
            return "email_verified"
        case .kycDocumentResubmission:
            return "verification"
        case .kyc:
            return "kyc"
        case .pitLinking:
            return nil
        }
    }
    
    private var optionalKeyParameter: String? {
        switch self {
        case .pitVerifyEmail,
             .kycVerifyEmail:
            return "context"
        case .kyc,
             .kycDocumentResubmission,
             .xlmAirdop,
             .pitLinking:
            return nil
        }
    }
}
