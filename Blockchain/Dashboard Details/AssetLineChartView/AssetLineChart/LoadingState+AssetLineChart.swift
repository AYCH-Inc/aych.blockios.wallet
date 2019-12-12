//
//  LoadingState+AssetLineChart.swift
//  Blockchain
//
//  Created by AlexM on 11/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts
import PlatformKit
import PlatformUIKit

extension LineChartData {
    convenience init(with value: AssetLineChart.Value.Interaction) {
        let presentationValue =  AssetLineChart.Value.Presentation(value: value)
        let entries = presentationValue.points.enumerated().map {
            ChartDataEntry(
                x: Double($0.element.x),
                y: Double($0.element.y),
                icon: nil,
                data: NSNumber(integerLiteral: $0.offset)
            )
        }
        let set = LineChartDataSet(entries: entries, label: nil)
        let gradients = [presentationValue.color.cgColor, UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradients, locations: [1.0, 0.0])!
        set.lineCapType = .round
        set.fill = Fill.fillWithLinearGradient(gradient, angle: 90)
        set.drawIconsEnabled = false
        set.mode = .cubicBezier
        set.cubicIntensity = 0.2
        set.lineWidth = 2.0
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.colors = [presentationValue.color]
        set.setCircleColor(.clear)
        set.highlightColor = presentationValue.color
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        set.drawFilledEnabled = true
        self.init(dataSet: set)
    }
    
    /// Returns an `empty` grayish pie chart data
    static var empty: LineChartData {
        let set = LineChartDataSet(entries: [ChartDataEntry(x: 0.0, y: 0.0)], label: nil)
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false
        set.drawVerticalHighlightIndicatorEnabled = false
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.highlightEnabled = false
        set.drawCirclesEnabled = false
        set.circleColors = [.clear]
        set.drawCircleHoleEnabled = false
        return LineChartData(dataSet: set)
    }
}

extension LoadingState where Content == (AssetLineChartMarkerView.Theme, LineChartData) {
    
    /// Initializer that receives the interaction state and
    /// maps it to `self`
    init(with state: LoadingState<AssetLineChart.Value.Interaction>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(let value):
            let theme: AssetLineChartMarkerView.Theme = value.delta >= 0 ? .positive: .negative
            self = .loaded(next: (theme, LineChartData(with: value)))
        }
    }
}

