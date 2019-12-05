//
//  AssetLineChartTableViewCellInteracting.swift
//  Blockchain
//
//  Created by AlexM on 11/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

/// `AssetLineChartTableViewCellInteracting` holds all the interactors
/// necessary for all the presenters built by `AssetLineChartTableViewCellPresenter`.
protocol AssetLineChartTableViewCellInteracting {
    
    /// An additional interactor used with `InstantAssetPriceViewInteractor`.
    /// This interactor responds to delegate call backs from the `LineChartView`
    var lineChartUserInteractor: AssetLineChartUserInteracting { get }
    
    /// The interactor for the `AssetLineChartPresenter`.
    var lineChartInteractor: AssetLineChartInteracting { get }
    
    /// The standard interactor for the `AssetPriceView`. In this case we are actually using
    /// `InstantAssetPriceViewInteractor` as the `AssetPriceView` shows values
    /// that the user selects on the `LineChartView`. When the user lets their finger
    /// off the `LineChartView` it shows the latest value again.
    /// `InstantAssetPriceViewInteractor` conforms to `AssetPriceViewInteracting`.
    var assetPriceViewInteractor: AssetPriceViewInteracting { get }
    
    /// `window` can be updated in response to events from the `SegmentedView`
    /// displayed above the `AssetLineChartTableViewcell`.
    var window: PublishRelay<PriceWindow> { get }
    
    /// Tells the presenter if the `AssetLineChartView` is currently
    /// deselected.
    var isDeselected: Driver<Bool> { get }
}

