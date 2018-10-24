//
//  URIScheme+Params.swift
//  Blockchain
//
//  Created by kevinwu on 10/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

extension URIScheme {
    private func get(payOperationParam: PayOperationParams, url: String) -> String? {
        let schemeAndOperation = "\(URISchemeName)\(PayOperation)"
        let fields = url.split(separator: "&")
        for field in fields {
            if field.hasPrefix(schemeAndOperation + "\(payOperationParam)") {
                return field.replacingOccurrences(of: "\(schemeAndOperation)\(payOperationParam)=", with: "")
            }
            if field.hasPrefix("\(payOperationParam)") {
                return field.replacingOccurrences(of: "\(payOperationParam)=", with: "")
            }
        }

        return nil
    }
}
