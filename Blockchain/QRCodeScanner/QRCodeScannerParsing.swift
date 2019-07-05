//
//  QRCodeScannerParsing.swift
//  Blockchain
//
//  Created by Jack on 16/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

protocol QRCodeScannerParsing {
    associatedtype T
    associatedtype U: Error
    
    func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<T, U>) -> Void)?)
}

final class AnyQRCodeScannerParsing<T, U: Error>: QRCodeScannerParsing {
    typealias CompletionHandler = ((Result<T, U>) -> Void)?
    
    private let parsingClosure: (Result<String, QRScannerError>, CompletionHandler) -> Void
    
    init<P: QRCodeScannerParsing>(parser: P) where P.T == T, P.U == U {
        self.parsingClosure = parser.parse
    }
    
    func parse(scanResult: Result<String, QRScannerError>, completion: CompletionHandler) {
        parsingClosure(scanResult, completion)
    }
}
