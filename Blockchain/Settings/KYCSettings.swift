//
//  KYCSettings.swift
//  Blockchain
//
//  Created by kevinwu on 12/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
class KycSettings: NSObject {
    static let shared = KycSettings()

    private let userDefaults: UserDefaults

    @objc class func sharedInstance() -> KycSettings {
        return shared
    }

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    var latestKycPage: KYCPageType? {
        get {
            let page = userDefaults.integer(forKey: UserDefaults.Keys.kycLatestPage.rawValue)
            return KYCPageType(rawValue: page)
        }
        set {
            if newValue == nil {
                userDefaults.set(nil, forKey: UserDefaults.Keys.kycLatestPage.rawValue)
                return
            }

            let previousPage = userDefaults.integer(forKey: UserDefaults.Keys.kycLatestPage.rawValue)
            guard let newPage = newValue, previousPage < newPage.rawValue else {
                Logger.shared.warning("\(newValue?.rawValue ?? 0) is not less than \(previousPage) for 'latestKycPage'.")
                return
            }
            userDefaults.set(newPage.rawValue, forKey: UserDefaults.Keys.kycLatestPage.rawValue)
        }
    }

    func reset() {
        latestKycPage = nil
    }
}
