//
//  AssetLineChartUserInteracting.swift
//  Blockchain
//
//  Created by AlexM on 11/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol AssetLineChartUserInteracting {
    var state: Observable<AssetLineChartInteractionState> { get }
}
