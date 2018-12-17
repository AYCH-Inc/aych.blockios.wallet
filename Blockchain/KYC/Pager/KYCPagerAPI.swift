//
//  KYCPagerAPI.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Handles paging from one `KYCPageType` to another.
protocol KYCPagerAPI {

    var tier: KYCTier { get }

    /// Returns the next page from the provided KYCPageType. This method also takes into account
    /// sanctioned checks such that if the rules engine determines that a user should be put
    /// through a higher tier KYC flow, this method will keep returning new pages.
    ///
    /// - Parameters:
    ///   - page: the page to return the next page from
    ///   - payload: an optional payload for the page
    /// - Returns: a Maybe which emits a KYCPageType if there is a next page, otherwise, returns nothing
    func nextPage(from page: KYCPageType, payload: KYCPagePayload?) -> Maybe<KYCPageType>
}
