//
//  Rx+Analytics.swift
//  PlatformKit
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Records analytics event using a given recorder on success
    public func recordOnSuccess(analyticsEvent: AnalyticsEvent,
                                using recorder: AnalyticsEventRecording) -> Single<Element> {
        return self.do(onSuccess: { _ in
            recorder.record(event: analyticsEvent)
        })
    }
    
    /// Records analytics event using a given recorder on error
    public func recordOnError(analyticsEvent: AnalyticsEvent,
                              using recorder: AnalyticsEventRecording) -> Single<Element> {
        return self.do(onError: { error in
              recorder.record(event: analyticsEvent)
        })
    }
    
    /// Records analytics event using a given recorder on any `Single` result
    public func recordOnResult(successEvent: AnalyticsEvent,
                               errorEvent: AnalyticsEvent,
                               using recorder: AnalyticsEventRecording) -> Single<Element> {
        return self.do(
            onSuccess: { _ in
                recorder.record(event: successEvent)
            },
            onError: { error in
              recorder.record(event: errorEvent)
            }
        )
    }
    
    /// Records analytics event using a given recorder on any `Single` lifecycle
    public func record(subscribeEvent: AnalyticsEvent,
                      successEvent: AnalyticsEvent,
                      errorEvent: AnalyticsEvent,
                      using recorder: AnalyticsEventRecording) -> Single<Element> {
        return self.do(
            onSuccess: { _ in
                recorder.record(event: successEvent)
            },
            onError: { error in
                recorder.record(event: errorEvent)
            },
            onSubscribe: {
                recorder.record(event: subscribeEvent)
            }
        )
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
extension ObservableType {
    
    /// Records analytics event using a given recorder
    public func record(analyticsEvent: AnalyticsEvent,
                       using recorder: AnalyticsEventRecording) -> Observable<Element> {
        return self.do(onNext: { _ in
            recorder.record(event: analyticsEvent)
        })
    }
}
