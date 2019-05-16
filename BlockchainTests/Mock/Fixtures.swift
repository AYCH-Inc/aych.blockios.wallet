//
//  Fixtures.swift
//  BlockchainTests
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class Fixtures {
    static func load<T: Decodable>(name: String) -> T? {
        guard let data = loadJSON(filename: name) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
    
    private static func loadJSON(filename: String) -> Data? {
        let testBundle = Bundle(for: Fixtures.self)
        guard let file = testBundle.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: file)
    }
}
