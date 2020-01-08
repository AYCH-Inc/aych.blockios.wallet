//
//  ExchangeAddressFetching.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol ExchangeAddressFetching {
    
    /// Fetches the Exchange address for a given asset type
    func fetchAddress(for asset: AssetType) -> Single<String>
}
