//
//  FiatCurrencyTypeProviding.swift
//  Blockchain
//
//  Created by Daniel Huri on 12/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// A protocol that provides a current configured currency semantics
protocol FiatCurrencyTypeProviding {
    var fiatCurrency: Observable<BlockchainSettings.App.FiatCurrency> { get }
}
