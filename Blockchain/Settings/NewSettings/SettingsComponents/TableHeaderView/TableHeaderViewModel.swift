//
//  SettingsTableHeaderViewModel.swift
//  Blockchain
//
//  Created by AlexM on 12/13/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

struct TableHeaderViewModel {
    
    /// The content color relay
    let contentColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The content color of the title
    var contentColor: Driver<UIColor> {
        return contentColorRelay.asDriver()
    }
    
    /// The text relay
    let textRelay = BehaviorRelay<String>(value: "")
    
    /// Text to be displayed on the badge
    var text: Driver<String> {
        return textRelay.asDriver()
    }
    
    let font: UIFont
    
    /// - parameter cornerRadius: corner radius of the component
    /// - parameter accessibility: accessibility for the view
    public init(font: UIFont = .mainMedium(12), title: String, textColor: UIColor) {
        self.font = font
        self.textRelay.accept(title)
        self.contentColorRelay.accept(textColor)
    }
}

extension TableHeaderViewModel {
    static func settings(title: String) -> TableHeaderViewModel {
        return .init(font: .mainSemibold(20), title: title, textColor: .titleText)
    }
}
