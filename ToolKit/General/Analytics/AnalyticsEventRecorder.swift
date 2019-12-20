//
//  AnalyticsEventRecorder.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

public class AnalyticsEventRecorder: AnalyticsEventRecording, AnalyticsEventRelayRecording {

    // MARK: - Properties
    
    public let recordRelay = PublishRelay<AnalyticsEvent>()
    
    private let analyticsService: AnalyticsServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(analyticsService: AnalyticsServiceAPI) {
        self.analyticsService = analyticsService
        
        recordRelay
            .subscribe(onNext: { [weak self] event in
                self?.record(event: event)
            })
            .disposed(by: disposeBag)
    }

    public func record(event: AnalyticsEvent) {
        analyticsService.trackEvent(title: event.name, parameters: event.params)
    }
}
