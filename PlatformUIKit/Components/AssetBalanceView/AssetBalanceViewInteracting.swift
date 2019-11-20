//
//  AssetBalanceViewInteracting.swift
//  Blockchain
//
//  Created by AlexM on 10/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol AssetBalanceViewInteracting: class {
    var state: Observable<DashboardAsset.State.AssetBalance.Interaction> { get }
}
