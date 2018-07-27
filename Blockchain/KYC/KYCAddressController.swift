//
//  KYCAddressController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class KYCAddressController: UIViewController, KYCOnboardingNavigation {

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var addressTextField: UITextField!
    @IBOutlet fileprivate var tableView: UITableView!

    // MARK: - Public IBOutlets

    @IBOutlet var primaryButton: PrimaryButton!

    // MARK: - KYCOnboardingNavigation

    var searchDelegate: SearchControllerDelegate?
    var segueIdentifier: String? = "showPersonalDetails"

    // MARK: Private Properties

    fileprivate let pageModel: LocationSuggestionPageModel = .empty
    fileprivate var coordinator: LocationSuggestionCoordinator!
    fileprivate var dataProvider: LocationDataProvider!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = LocationSuggestionCoordinator(self)
        dataProvider = LocationDataProvider(with: tableView)
        addressTextField.delegate = self
        tableView.delegate = self
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        guard let identifier = segueIdentifier else { return }
        performSegue(withIdentifier: identifier, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }
}

extension KYCAddressController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = dataProvider.locationResult.suggestions[indexPath.row]
        coordinator.onSelection(selection)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addressTextField.resignFirstResponder()
    }
}

extension KYCAddressController: LocationSuggestionCoordinatorDelegate {
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, updated model: LocationSearchResult) {
        dataProvider.locationResult = model
    }
}

extension KYCAddressController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty == false else {
            return false
        }

        searchDelegate?.onSearchSubmission(text)
        textField.resignFirstResponder()
        return true
    }
}
