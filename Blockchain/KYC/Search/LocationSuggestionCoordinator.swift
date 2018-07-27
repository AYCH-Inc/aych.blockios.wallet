//
//  LocationSuggestionCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol LocationSuggestionCoordinatorDelegate: class {
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, updated model: LocationSearchResult)
}

class LocationSuggestionCoordinator: NSObject {

    fileprivate let service: LocationSuggestionService
    fileprivate var model: LocationSearchResult {
        didSet {
            delegate?.coordinator(self, updated: model)
        }
    }
    fileprivate weak var delegate: LocationSuggestionCoordinatorDelegate?

    init(_ delegate: LocationSuggestionCoordinatorDelegate) {
        self.service = LocationSuggestionService()
        self.delegate = delegate
        self.model = .empty
        super.init()

        if let controller = delegate as? KYCAddressController {
            controller.searchDelegate = self
        }
    }
}

extension LocationSuggestionCoordinator: SearchControllerDelegate {

    func onSelection(_ selection: SearchSelection) {
        if let input = selection as? LocationSuggestion {
            service.selected(suggestion: input)
        }
    }

    func onSearchSubmission(_ query: String) {
        var newModel = model
        newModel.state = .loading
        model = newModel

        service.search(for: query) { [weak self] (suggestions, error) in
            guard let this = self else { return }
            let state: LocationSearchResult.SearchUIState = error != nil ? .error(error) : .success
            let result = LocationSearchResult(
                state: state,
                suggestions: suggestions ?? []
            )
            this.model = result
        }
    }

    func onSearchViewCancel() {
        guard service.isExecuting else { return }
        service.cancel()
    }
}
