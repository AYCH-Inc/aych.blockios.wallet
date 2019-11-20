//
//  FiatCurrencyTypeProviding.swift
//  Blockchain
//
//  Created by Daniel Huri on 12/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// A protocol that provides a current configured currency semantics
public protocol FiatCurrencyTypeProviding {
    var fiatCurrency: Observable<Settings.FiatCurrency> { get }
}
