//
//  TextValidating.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// A source of text stream
public protocol TextSource: class {
    var valueRelay: BehaviorRelay<String> { get }
}

/// Text validation mechanism
public protocol TextValidating: TextSource {
    var isValid: Observable<Bool> { get }
}
