//
//  AssetPieChartInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol AssetPieChartInteracting: class {
    var state: Observable<AssetPieChart.State.Interaction> { get }
}
