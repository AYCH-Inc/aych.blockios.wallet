//
//  Encodable+Dictionary.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension Encodable {
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] ?? [:]
    }
    
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
    
    func encodeToString(encoding: String.Encoding) throws -> String {
        let encodedData = try self.encode()
        guard let string = String(data: encodedData, encoding: encoding) else {
            throw EncodingError.invalidValue(
                encodedData,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Could not create string with given encoding."
                )
            )
        }
        return string
    }
    
    func toDictionary() throws -> [String: Any] {
        guard let data = try? self.encode(), let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
            ) as? [String: Any] else {
                throw NSError(domain: "Encodable", code: 0, userInfo: nil)
        }
        return dictionary
    }
    
    func tryToEncode(
        encoding: String.Encoding,
        onSuccess: (String) -> Void,
        onError: () -> Void
        ) {
        do {
            let encodedData = try self.encode()
            guard let string = String(data: encodedData, encoding: encoding) else {
                onError()
                return
            }
            onSuccess(string)
        } catch {
            onError()
        }
    }
}
