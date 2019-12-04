//
//  AssetLineChartTableViewCellPresenting.swift
//  Blockchain
//
//  Created by AlexM on 11/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformUIKit
import RxCocoa
import PlatformKit
import Charts

protocol AssetLineChartTableViewCellPresenting {
    /// `LineChartView` may seem out of place here, however
    /// we must inject the `LineChartView` into the `AssetLineChartTableViewCellInteractor`
    /// in order to respond to delegate callbacks at the interactor
    /// level. These delegate callbacks tell us what the user
    /// has selected and when they have deselected the chart.
    /// By having this at the presentation layer we are able to
    /// not only inject the `LineChartView`, but add it as a
    /// subview to the `AssetLineChartTableViewCell`
    var lineChartView: LineChartView { get }
    
    /// `window` emits the selected `PriceWindow`. The selection
    /// comes from `MultiActionViewInteracting`.
    var window: Signal<PriceWindow> { get }
    
    /// Should the user be interacting with the `LineChartView`
    /// we want to prohibit scrolling.
    var isScrollEnabled: Driver<Bool> { get }
    
    /// A container of presenters used in the `AsserLineChartTableViewCell`.
    /// This just makes it easier for injecting the individual presenters
    /// used for each subview. It also contains the `LineChartView`
    var presenterContainer: AssetLineChartPresenterContainer { get }
    
    /// The presenter used for the `MultiActionTableViewCell`. This
    /// takes a `MultiActionViewInteracting` which provides the actions
    /// that trigger the `PriceWindow` relay.
    var priceWindowPresenter: MultiActionViewPresenting { get }
}

