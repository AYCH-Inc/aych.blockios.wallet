//
//  AnnouncementRecord+State.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

extension AnnouncementRecord {
    
    enum State {
        
        // MARK: - Types
        
        private enum Base: String, Codable {
            case removed
            case valid
            case dismissed
        }
        
        private enum CodingKeys: CodingKey {
            case removed
            case valid
            case dateOfDismissal
            case numberOfDismissals
        }
        
        // MARK: - Cases
        
        /// Dismissed state with associated date of dismissal and the number of times
        /// the announcement has been dismissed so far
        case dismissed(on: Date, count: Int)
        
        /// Permanent removal of announcement
        case removed
        
        /// Valid state of record
        case valid
    }
}

// MARK: - Decodable

extension AnnouncementRecord.State: Decodable {
    
    enum DecodingError: Error {
        case parse
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _ = try? container.decode(Base.self, forKey: .valid) {
            self = .valid
        } else if let _ = try? container.decode(Base.self, forKey: .removed) {
            self = .removed
        } else if let date = try? container.decode(Date.self, forKey: .dateOfDismissal),
                  let count = try? container.decode(Int.self, forKey: .numberOfDismissals) {
            self = .dismissed(on: date, count: count)
        } else {
            throw DecodingError.parse
        }
    }
}

// MARK: - Encodable

extension AnnouncementRecord.State: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .valid:
            try container.encode(Base.valid, forKey: .valid)
        case .removed:
            try container.encode(Base.removed, forKey: .removed)
        case .dismissed(on: let date, count: let count):
            try container.encode(date, forKey: .dateOfDismissal)
            try container.encode(count, forKey: .numberOfDismissals)
        }
    }
}
