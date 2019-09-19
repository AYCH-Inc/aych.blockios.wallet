//
//  Data+Codable.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension Data {
    
    /// Data -> `Decodable` using the type `T: Decodable`
    func decode<T: Decodable>(to type: T.Type) throws -> T {
        let decoded: T
        do {
            decoded = try JSONDecoder().decode(type, from: self)
        } catch {
            throw error
        }
        return decoded
    }
}

public extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
