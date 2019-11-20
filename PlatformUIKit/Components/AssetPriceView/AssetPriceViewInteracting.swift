//
//  AssetPriceViewInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol AssetPriceViewInteracting: class {
    var state: Observable<DashboardAsset.State.AssetPrice.Interaction> { get }
}
