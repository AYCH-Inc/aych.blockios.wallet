//
//  NavigationBarButtonItem.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class NavigationBarButtonItem: UIBarButtonItem {
    
    // MARK: - Types
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    enum ItemType {
        case processing
        case content(content: Screen.NavigationBarContent, tap: () -> Void)
        case none
    }
    
    init(type: ItemType, color: UIColor) {
        super.init()
        
        self.tintColor = color
        self.target = self
        self.style = .plain
        
        switch type {
        case .content(content: let content, tap: let tap):
            let font = Font(.branded(.montserratSemiBold), size: .custom(14))
            let attributes: [NSAttributedString.Key: Any] = [.font: font.result,
                                                             .foregroundColor: color]
            self.setTitleTextAttributes(attributes, for: .normal)
            self.setTitleTextAttributes(attributes, for: .highlighted)
            self.setTitleTextAttributes(attributes, for: .disabled)
            self.title = content.title
            self.image = content.image
            
            self.rx.tap.bind {
                tap()
            }.disposed(by: disposeBag)
            
        case .processing:
            let activityIndicator = UIActivityIndicatorView(style: .white)
            self.customView = activityIndicator
            activityIndicator.startAnimating()
        case .none:
            self.customView = nil
            self.title = nil
            self.image = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) is not implemented")
    }
}
