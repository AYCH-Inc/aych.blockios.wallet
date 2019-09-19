//
//  BridgedDisposeBag.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// This class is a workaround for Swift-ObjC interoperability when involving RxSwift code.
/// It is handy in times we want to extend an ObjC class using Swift (gradual migration).
@objc
public class BridgedDisposeBag: NSObject {
    public let bag = DisposeBag()
}
