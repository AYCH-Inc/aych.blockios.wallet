//
//  LoadingViewProtocol.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 16/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol LoadingViewProtocol {
    func animate(from oldState: LoadingViewPresenter.State, text: String?)
    func fadeOut()
    var viewRepresentation: UIView { get }
}

extension LoadingViewProtocol where Self: UIView {
    var viewRepresentation: UIView {
        return self as UIView
    }
}
