//
//  AssetLineChartInteracting.swift
//  Blockchain
//
//  Created by AlexM on 11/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformKit

protocol AssetLineChartInteracting: class {
    
    var priceWindowRelay: PublishRelay<PriceWindow> { get }
    
    var state: Observable<AssetLineChart.State.Interaction> { get }
}

