//
//  Fixtures.swift
//  BlockchainTests
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class Fixtures {
    
    public static func load<T: Decodable>(name: String, in bundle: Bundle) -> T? {
        guard let data = loadJSON(filename: name, in: bundle) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
    
    private static func loadJSON(filename: String, in bundle: Bundle) -> Data? {
        guard let file = bundle.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: file)
    }
}
