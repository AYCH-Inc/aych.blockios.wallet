//
//  LocationSuggestionPageModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct LocationSearchResult {
    enum SearchUIState {
        case loading
        case error(Error?)
        case success
        case empty
    }

    var state: SearchUIState = .empty
    var suggestions: [LocationSuggestion] = []
}

extension LocationSearchResult {
    static let empty = LocationSearchResult(
        state: .empty,
        suggestions: []
    )
}

struct LocationSuggestionPageModel {

    var searchResult: LocationSearchResult
    let title: String
    let placeholder: String
    let CTATitle: String

    init(title: String, placeholder: String, CTATitle: String, searchResult: LocationSearchResult = .empty) {
        self.title = title
        self.placeholder = placeholder
        self.CTATitle = CTATitle
        self.searchResult = searchResult
    }
}

extension LocationSuggestionPageModel {
    static let empty = LocationSuggestionPageModel(
        title: "What's Your Address?",
        placeholder: "Enter Address",
        CTATitle: "Search My Address"
    )
}
