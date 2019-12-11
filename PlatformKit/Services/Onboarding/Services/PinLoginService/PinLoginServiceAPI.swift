//
//  PinLoginServiceAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// This service API is used to decrypt the password from the pin decryption key.
public protocol PinLoginServiceAPI: class {
    func password(from pinDecryptionKey: String) -> Single<String>
}
