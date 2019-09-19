//
//  PulseContainerViewProtocol.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/26/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxCocoa

protocol PulseContainerViewProtocol {
    func animate()
    func fadeOut()
    var selection: Signal<Void> { get }
    var viewRepresentation: PassthroughView { get }
}

extension PulseContainerViewProtocol where Self: PassthroughView {
    var viewRepresentation: PassthroughView {
        return self as PassthroughView
    }
}
