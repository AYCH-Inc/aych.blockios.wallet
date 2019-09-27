//
//  AppFeatureConfigurator.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Firebase
import RxSwift

@objc class AppFeatureConfigurator: NSObject, FeatureConfiguring {
    
    enum ConfigurationError: Error {
        case missingKeyRawValue
        case missingValue
    }
    
    static let shared = AppFeatureConfigurator()

    /// Class function to retrieve the AppFeatureConfigurator shared instance for obj-c compatibility.
    @objc class func sharedInstance() -> AppFeatureConfigurator { return shared }

    private let remoteConfig: RemoteConfig

    private override init() {
        remoteConfig = RemoteConfig.remoteConfig()
        super.init()
        setDefaultConfigs()
    }

    /// Returns an `AppFeatureConfiguration` object for the provided feature.
    ///
    /// - Parameter feature: the feature
    /// - Returns: the configuration for the feature requested
    @objc func configuration(for feature: AppFeature) -> AppFeatureConfiguration {

        // If there is no remote key defined for the feature (i.e. if it is not controlled via Firebase),
        // it is enabled by default
        guard let remoteEnabledKey = feature.remoteEnabledKey else {
            return AppFeatureConfiguration(isEnabled: true)
        }

        let isEnabled = remoteConfig.configValue(forKey: remoteEnabledKey).boolValue
        return AppFeatureConfiguration(isEnabled: isEnabled)
    }

    func initialize() {
        fetchRemoteConfig()
    }

    private func fetchRemoteConfig() {
        #if DEBUG
        let expiration = TimeInterval(60) // 1 min
        #else
        let expiration = TimeInterval(4 * 60 * 60) // 4 hours
        #endif
        remoteConfig.fetch(withExpirationDuration: expiration) { [weak self] status, error in
            guard let strongSelf = self else { return }
            guard status == .success && error == nil else {
                print("config fetch error")
                return
            }
            strongSelf.remoteConfig.activateFetched()
        }
    }

    // MARK: - Private

    private func setDefaultConfigs() {
        remoteConfig.setDefaults([
            AppFeature.stellarAirdrop.remoteEnabledKey!: "false" as NSString
        ])
    }
}

// MARK: - FeatureDecoding

extension AppFeatureConfigurator: FeatureFetching {

    /// Returns an expected decodable construct for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the decodable object wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value
    /// of the feature is missing or another error if the decoding has failed.
    func fetch<Feature: Decodable>(for key: AppFeature) -> Single<Feature> {
        guard let keyRawValue = key.remoteEnabledKey else {
            return .error(ConfigurationError.missingKeyRawValue)
        }
        let data = remoteConfig.configValue(forKey: keyRawValue).dataValue
        do {
            let feature = try data.decode(to: Feature.self)
            return .just(feature)
        } catch {
            return .error(error)
        }
    }
    
    /// Returns an expected string for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the string value wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value
    /// is missing or `ConfigurationError.missingValue` if the value itself is missing.
    func fetchString(for key: AppFeature) -> Single<String> {
        guard let keyRawValue = key.remoteEnabledKey else {
            return .error(ConfigurationError.missingKeyRawValue)
        }
        guard let value = remoteConfig.configValue(forKey: keyRawValue).stringValue else {
            return .error(ConfigurationError.missingValue)
        }
        return .just(value)
    }
    
    /// Returns an expected variant for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value
    /// is missing or `ConfigurationError.missingValue` if the value itself is missing.
    func fetchTestingVariant(for key: AppFeature) -> Single<FeatureTestingVariant> {
        return fetchString(for: key)
            .map { FeatureTestingVariant(rawValue: $0) ?? .variantA }
    }
    
    /// Returns an expected integer for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the integer value wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value
    /// is missing or `ConfigurationError.missingValue` if the value itself is missing.
    func fetchInteger(for key: AppFeature) -> Single<Int> {
        guard let keyRawValue = key.remoteEnabledKey else {
            return .error(ConfigurationError.missingKeyRawValue)
        }
        guard let number = remoteConfig.configValue(forKey: keyRawValue).numberValue?.intValue else {
            return .error(ConfigurationError.missingValue)
        }
        return .just(number)
    }
}
