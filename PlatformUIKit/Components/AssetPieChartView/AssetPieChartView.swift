//
//  PieChatView.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import PlatformKit
import RxSwift
import RxRelay
import RxCocoa

/// An Rx driven pie-chart view
public final class AssetPieChartView: UIView {
    
    // MARK: - Injected
    
    /// Presenter is injected from external source
    /// because the view should be compatible with queueing
    /// mechanism.
    public var presenter: AssetPieChartPresenter! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else { return }
            presenter.state
                .compactMap { $0.value }
                .bind(to: rx.chartData)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Properties
    
    fileprivate lazy var chartView: PieChartView = {
        let chartView = PieChartView(frame: bounds)
        chartView.drawCenterTextEnabled = false
        chartView.drawEntryLabelsEnabled = false
        chartView.usePercentValuesEnabled = false
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.rotationEnabled = false
        chartView.holeRadiusPercent = 0.875
        chartView.transparentCircleRadiusPercent = 0
        chartView.chartDescription?.enabled = false
        chartView.drawCenterTextEnabled = true
        chartView.drawHoleEnabled = true
        chartView.legend.enabled = false
        chartView.rotationAngle = -90 // Default is rhs. should be rotated counter clockwise
        chartView.highlightPerTapEnabled = false
        return chartView
    }()
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(chartView)
        chartView.fillSuperview()
        chartView.data = PieChartData.empty
    }
}

// MARK: - Rx

fileprivate extension Reactive where Base: AssetPieChartView {
    var chartData: Binder<PieChartData> {
        return Binder(base) { view, data in
            view.chartView.data = data
            view.chartView.setNeedsDisplay()
        }
    }
}
