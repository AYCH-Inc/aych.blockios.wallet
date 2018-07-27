//
//  LocationSuggestionAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias LocationSuggestionCompletion = (([LocationSuggestion]?, Error?) -> Void)

protocol LocationSuggestionAPI {
    func search(for query: String, with completion: @escaping LocationSuggestionCompletion)
    func selected(suggestion: LocationSuggestion)
    func cancel()
    var isExecuting: Bool { get }
}

