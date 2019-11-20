//
//  AssetPieChartPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Charts

/// A presentation layer for asset pie chart
public final class AssetPieChartPresenter {
        
    // MARK: - Properties
    
    /// The size of the pie chart as derivative of the edge
    var size: CGSize {
        return CGSize(width: edge, height: edge)
    }
    
    /// Streams the state of pie-chart
    var state: Observable<AssetPieChart.State.Presentation> {
        return stateRelay
            .observeOn(MainScheduler.instance)
    }
    
    private let edge: CGFloat
    private let interactor: AssetPieChartInteracting
            
    /// The state relay. Starts with a `.loading` state
    private let stateRelay = BehaviorRelay<AssetPieChart.State.Presentation>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(edge: CGFloat,
                interactor: AssetPieChartInteracting) {
        self.edge = edge
        self.interactor = interactor
        interactor.state
            .map { .init(with: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
