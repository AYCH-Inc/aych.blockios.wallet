//
//  AssetLineChartPresenter.swift
//  Blockchain
//
//  Created by AlexM on 11/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Charts
import PlatformKit

/// A presentation layer for asset line chart
final class AssetLineChartPresenter {
        
    // MARK: - Properties
    
    /// The size of the line chart as derivative of the edge
    var size: CGSize {
        return CGSize(width: edge, height: edge)
    }
    
    /// Streams the state of pie-chart
    var state: Observable<AssetLineChart.State.Presentation> {
        return stateRelay
            .observeOn(MainScheduler.instance)
    }
    
    private let edge: CGFloat
    private let interactor: AssetLineChartInteracting
            
    /// The state relay. Starts with a `.loading` state
    private let stateRelay = BehaviorRelay<AssetLineChart.State.Presentation>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(edge: CGFloat,
         interactor: AssetLineChartInteracting) {
        self.edge = edge
        self.interactor = interactor
        
        interactor.state
            .map { .init(with: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
