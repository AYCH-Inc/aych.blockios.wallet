//
//  Accessibility+DashboardComponents.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 06/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

extension Accessibility.Identifier {
    public struct Dashboard {
        private static let prefix = "Dashboard."
        struct Notice {
            private static let prefix = "\(Dashboard.prefix)Notice."
            static let label = "\(prefix)label"
            static let imageView = "\(prefix)imageView"
        }
        public struct TotalBalanceCell {
            private static let prefix = "\(Dashboard.prefix)TotalBalanceCell."
            public static let titleLabel = "\(prefix)titleLabel"
            public static let valueLabelSuffix = "\(prefix)total"
            public static let pieChartView = "\(prefix)pieChartView"
        }
        public struct AssetCell {
            private static let prefix = "\(Dashboard.prefix)AssetCell."
            public static let titleLabelFormat = "\(prefix)titleLabel."
            public static let assetImageView = "\(prefix)assetImageView."
            public static let fiatPriceLabelFormat = "\(prefix)fiatPriceLabelFormat."
            public static let changeLabelFormat = "\(prefix)changeLabelFormat."
            public static let fiatBalanceLabelFormat = "\(prefix)fiatBalanceLabel."
            public static let cryptoBalanceLabelFormat = "\(prefix)cryptoBalanceLabel."
        }
        struct Announcement {
            private static let prefix = "\(Dashboard.prefix)Announcement."
            
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let imageView = "\(prefix)thumbImageView"
            static let dismissButton = "\(prefix)dismissButton"
        }
    }
}
