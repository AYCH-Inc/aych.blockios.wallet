//
//  SettingsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class SettingsService: SettingsServiceAPI {
    
    // MARK: - Types

    enum ServiceError: Error {
        case missingSharedKey
        case missingGuid
    }
    
    public typealias CalculationState = ValueCalculationState<WalletSettings>

    // MARK: - Exposed Properties
    
    /// The state of the calculation
    public var state: Observable<CalculationState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Properties

    private let client: SettingsClientAPI
    private let credentialsRepository: GuidRepositoryAPI & SharedKeyRepositoryAPI

    public let fetchTriggerRelay = PublishRelay<Void>()
    private let stateRelay = BehaviorRelay<CalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    /// GUID and Shared-Key credentials are necessary to settings operations.
    private var credentials: Single<(guid: String, sharedKey: String)> {
        return Single
            // Make sure guid and shared key exist
            .zip(credentialsRepository.guid, credentialsRepository.sharedKey)
            .map { (guid, sharedKey) -> (guid: String, sharedKey: String) in
                guard let guid = guid else {
                    throw ServiceError.missingGuid
                }
                guard let sharedKey = sharedKey else {
                    throw ServiceError.missingSharedKey
                }
                return (guid, sharedKey)
            }
    }
    
    // MARK: - Setup
    
    public init(client: SettingsClientAPI = SettingsClient(),
                credentialsRepository: GuidRepositoryAPI & SharedKeyRepositoryAPI) {
        self.client = client
        self.credentialsRepository = credentialsRepository
        
        fetchTriggerRelay
            .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest(weak: self) { (self, _) -> Observable<SettingsResponse> in
                self.credentials
                    .flatMap(weak: self) { (self, credentials) -> Single<SettingsResponse> in
                        self.client.settings(
                            by: credentials.guid,
                            sharedKey: credentials.sharedKey
                        )
                    }
                    .asObservable()
            }
            .map { WalletSettings(response: $0) }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    
    /// Refreshes the wallet settings - triggers a recalculation of `CalculationState`.
    public func refresh() {
        fetchTriggerRelay.accept(())
    }
}

// MARK: - SettingsEmailUpdateServiceAPI

extension SettingsService: EmailSettingsServiceAPI {

    public var email: Single<String> {
        return stateRelay
            .compactMap { $0.value }
            .map { $0.email }
            .take(1)
            .asSingle()
    }
    
    public func update(email: String, context: FlowContext?) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    email: email,
                    context: context,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
    }
}

// MARK: - LastTransactionSettingsUpdateServiceAPI

extension SettingsService: LastTransactionSettingsUpdateServiceAPI {
    public func updateLastTransaction() -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.updateLastTransactionTime(
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
    }
}

// MARK: - EmailNotificationSettingsServiceAPI

extension SettingsService: EmailNotificationSettingsServiceAPI {
    public func emailNotifications(enabled: Bool) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.emailNotifications(
                    enabled: enabled,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
    }
}
