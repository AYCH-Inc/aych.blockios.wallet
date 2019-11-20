//
//  TabBarPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class TabBarPresenter {
    
    let itemContentArray: [TabItemContent] = {
        return [
            TabItemContent(
                title: LocalizationConstants.TabItems.home,
                image: "icon_home",
                selectedImage: "icon_home",
                accessibility: .init(id: .value(Accessibility.Identifier.TabItem.home))
            ),
            TabItemContent(
                title: LocalizationConstants.TabItems.activity,
                image: "icon_activity",
                selectedImage: "icon_activity",
                accessibility: .init(id: .value(Accessibility.Identifier.TabItem.activity))
            ),
            TabItemContent(
                title: LocalizationConstants.TabItems.swap,
                image: "icon_swap",
                selectedImage: "icon_swap",
                accessibility: .init(id: .value(Accessibility.Identifier.TabItem.swap))
            ),
            TabItemContent(
                title: LocalizationConstants.TabItems.send,
                image: "icon_send",
                selectedImage: "icon_send",
                accessibility: .init(id: .value(Accessibility.Identifier.TabItem.send))
            ),
            TabItemContent(
                title: LocalizationConstants.TabItems.request,
                image: "icon_request",
                selectedImage: "icon_request",
                accessibility: .init(id: .value(Accessibility.Identifier.TabItem.request))
            )
        ]
    }()
}
