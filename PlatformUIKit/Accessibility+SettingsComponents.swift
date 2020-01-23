//
//  Accessibility+SettingsComponents.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Accessibility.Identifier {
    public struct Settings {
        private static let prefix = "Settings."
        public struct SettingsCell {
            private static let prefix = "\(Settings.prefix)SettingsCell."
            public static let titleLabelFormat = "\(prefix)titleLabel."
            public static let badgeView = "\(prefix)badgeView."
        }
    }
}
