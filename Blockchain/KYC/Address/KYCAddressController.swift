//
//  KYCAddressController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import UIKit

class KYCAddressController: KYCBaseViewController, ValidationFormView, BottomButtonContainerView {

    // MARK: BottomButtonContainerView

    var optionalOffset: CGFloat = 0
    var originalBottomButtonConstraint: CGFloat!
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var progressView: UIProgressView!
    @IBOutlet fileprivate var searchBar: UISearchBar!
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var labelFooter: UILabel!
    @IBOutlet fileprivate var requiredLabel: UILabel!
    
    // MARK: Private IBOutlets (ValidationTextField)
    @IBOutlet fileprivate var addressTextField: ValidationTextField!
    @IBOutlet fileprivate var apartmentTextField: ValidationTextField!
    @IBOutlet fileprivate var cityTextField: ValidationTextField!
    @IBOutlet fileprivate var stateTextField: ValidationTextField!
    @IBOutlet fileprivate var postalCodeTextField: ValidationTextField!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!

    private let analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared

    // MARK: - Public IBOutlets

    @IBOutlet var scrollView: UIScrollView!

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCAddressController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .address
        return controller
    }

    // MARK: - KYCOnboardingNavigation

    weak var searchDelegate: SearchControllerDelegate?

    /// `validationFields` are all the fields listed below in a collection.
    /// This is just for convenience purposes when iterating over the fields
    /// and checking validation etc.
    var validationFields: [ValidationTextField] {
        return [addressTextField,
                apartmentTextField,
                cityTextField,
                stateTextField,
                postalCodeTextField
        ]
    }

    var keyboard: KeyboardPayload?

    // MARK: Private Properties

    fileprivate var locationCoordinator: LocationSuggestionCoordinator!
    fileprivate var dataProvider: LocationDataProvider!
    private var user: NabuUser?
    private var country: KYCCountry?

    // MARK: KYCCoordinatorDelegate

    override func apply(model: KYCPageModel) {
        guard case let .address(user, country) = model else { return }
        self.user = user
        self.country = country
        if let country = self.country {
            validationFieldsPlaceholderSetup(country.code)
        }
        
        guard let address = user.address else { return }
        addressTextField.text = address.lineOne
        apartmentTextField.text = address.lineTwo
        postalCodeTextField.text = address.postalCode
        cityTextField.text = address.city
        stateTextField.text = address.state
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        locationCoordinator = LocationSuggestionCoordinator(self, interface: self)
        dataProvider = LocationDataProvider(with: tableView)
        searchBar.delegate = self
        tableView.delegate = self
        scrollView.alwaysBounceVertical = true

        searchBar.barTintColor = .clear
        searchBar.placeholder = LocalizationConstants.KYC.yourHomeAddress

        progressView.tintColor = .green
        requiredLabel.text = LocalizationConstants.KYC.required + "*"

        initFooter()
        validationFieldsSetup()
        setupNotifications()

        primaryButtonContainer.title = LocalizationConstants.KYC.submit
        primaryButtonContainer.actionBlock = { [weak self] in
            guard let this = self else { return }
            this.primaryButtonTapped()
        }

        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
    }

    deinit {
        cleanUp()
    }

    // MARK: IBActions

    @IBAction func onFooterTapped(_ sender: UITapGestureRecognizer) {
        guard let text = labelFooter.text else {
            return
        }
        if let tosRange = text.range(of: LocalizationConstants.tos),
            sender.didTapAttributedText(in: labelFooter, range: NSRange(tosRange, in: text)) {
            UIApplication.shared.openWebView(
                url: Constants.Url.termsOfService,
                title: LocalizationConstants.tos,
                presentingViewController: self
            )
        }
        if let privacyPolicyRange = text.range(of: LocalizationConstants.privacyPolicy),
            sender.didTapAttributedText(in: labelFooter, range: NSRange(privacyPolicyRange, in: text)) {
            UIApplication.shared.openWebView(
                url: Constants.Url.privacyPolicy,
                title: LocalizationConstants.privacyPolicy,
                presentingViewController: self
            )
        }
    }

    // MARK: Private Functions

    private func initFooter() {
        // TICKET: IOS-1436
        // Tap target is a bit off here. Refactor ActionableLabel to take in 2 CTAs
        let font = Font(.branded(.montserratRegular), size: .custom(15.0)).result
        let labelAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.gray5
        ]
        let labelText = NSMutableAttributedString(
            string: String(
                format: LocalizationConstants.KYC.termsOfServiceAndPrivacyPolicyNoticeAddress,
                LocalizationConstants.tos,
                LocalizationConstants.privacyPolicy
            ),
            attributes: labelAttributes
        )
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.tos)
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.privacyPolicy)
        labelFooter.attributedText = labelText
    }

    fileprivate func validationFieldsSetup() {

        /// Given that this is a form, we want all the fields
        /// except for the last one to prompt the user to
        /// continue to the next field.
        /// We also set the contentType that the field is expecting.
        addressTextField.returnKeyType = .next
        addressTextField.contentType = .streetAddressLine1

        apartmentTextField.returnKeyType = .next
        apartmentTextField.contentType = .streetAddressLine2

        cityTextField.returnKeyType = .next
        cityTextField.contentType = .addressCity

        stateTextField.returnKeyType = .next
        stateTextField.contentType = .addressState

        postalCodeTextField.returnKeyType = .done
        postalCodeTextField.contentType = .postalCode

        validationFields.enumerated().forEach { (index, field) in
            field.returnTappedBlock = { [weak self] in
                guard let this = self else { return }
                guard this.validationFields.count > index + 1 else {
                    field.resignFocus()
                    return
                }
                let next = this.validationFields[index + 1]
                next.becomeFocused()
            }
        }

        handleKeyboardOffset()
    }
    
    fileprivate func validationFieldsPlaceholderSetup(_ countryCode: String) {
        if countryCode == "US" {
            addressTextField.placeholder = LocalizationConstants.KYC.streetLine + " 1"
            addressTextField.optionalField = false
            
            apartmentTextField.placeholder = LocalizationConstants.KYC.streetLine + " 2"
            apartmentTextField.optionalField = true
            
            cityTextField.placeholder = LocalizationConstants.KYC.city
            cityTextField.optionalField = false
            
            stateTextField.placeholder = LocalizationConstants.KYC.state
            stateTextField.optionalField = false
            
            postalCodeTextField.placeholder = LocalizationConstants.KYC.zipCode
            postalCodeTextField.optionalField = false
        } else {
            addressTextField.placeholder = LocalizationConstants.KYC.addressLine + " 1"
            addressTextField.optionalField = false
            
            apartmentTextField.placeholder = LocalizationConstants.KYC.addressLine + " 2"
            apartmentTextField.optionalField = true
            
            cityTextField.placeholder = LocalizationConstants.KYC.cityTownVillage
            cityTextField.optionalField = false
            
            stateTextField.placeholder = LocalizationConstants.KYC.stateRegionProvinceCountry
            stateTextField.optionalField = false
            
            postalCodeTextField.placeholder = LocalizationConstants.KYC.postalCode
            postalCodeTextField.optionalField = true
        }
        
        validationFields.forEach { field in
            if field.optionalField == false {
                field.placeholder += "*"
            }
        }
    }

    fileprivate func setupNotifications() {
        NotificationCenter.when(UIResponder.keyboardWillHideNotification) { [weak self] _ in
            self?.scrollView.contentInset = .zero
            self?.scrollView.setContentOffset(.zero, animated: true)
        }
    }

    fileprivate func primaryButtonTapped() {
        guard checkFieldsValidity() else { return }

        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycAddressDetailSet)
        
        validationFields.forEach({$0.resignFocus()})

        let address = UserAddress(
            lineOne: addressTextField.text ?? "",
            lineTwo: apartmentTextField.text ?? "",
            postalCode: postalCodeTextField.text ?? "",
            city: cityTextField.text ?? "",
            state: stateTextField.text ?? "",
            countryCode: country?.code ?? user?.address?.countryCode ?? ""
        )
        searchDelegate?.onSubmission(address, completion: { [weak self] in
            guard let this = self else { return }
            this.coordinator.handle(event: .nextPageFromPageType(this.pageType, nil))
        })
    }
}

extension KYCAddressController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = dataProvider.locationResult.suggestions[indexPath.row]
        locationCoordinator.onSelection(selection)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension KYCAddressController: LocationSuggestionInterface {
    func termsOfServiceDisclaimer(_ visibility: Visibility) {
        labelFooter.alpha = visibility.defaultAlpha
    }
    
    func primaryButtonActivityIndicator(_ visibility: Visibility) {
        primaryButtonContainer.isLoading = visibility == .visible
    }

    func primaryButtonEnabled(_ enabled: Bool) {
        primaryButtonContainer.isEnabled = enabled
    }

    func addressEntryView(_ visibility: Visibility) {
        scrollView.alpha = visibility.defaultAlpha
    }

    func populateAddressEntryView(_ address: PostalAddress) {
        if let number = address.streetNumber, let street = address.street {
            addressTextField.text = "\(number) \(street)"
        }
        cityTextField.text = address.city
        stateTextField.text = address.state
        postalCodeTextField.text = address.postalCode
    }

    func updateActivityIndicator(_ visibility: Visibility) {
        visibility == .hidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }

    func suggestionsList(_ visibility: Visibility) {
        tableView.alpha = visibility.defaultAlpha
    }

    func primaryButton(_ visibility: Visibility) {
        primaryButtonContainer.alpha = visibility.defaultAlpha
    }

    func searchFieldActive(_ isFirstResponder: Bool) {
        switch isFirstResponder {
        case true:
            searchBar.becomeFirstResponder()
        case false:
            searchBar.resignFirstResponder()
        }
    }

    func searchFieldText(_ value: String?) {
        searchBar.text = value
    }
}

extension KYCAddressController: LocationSuggestionCoordinatorDelegate {
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, generated address: PostalAddress) {
        // TODO: May not be needed depending on how we pass along the `PostalAddress`
    }

    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, updated model: LocationSearchResult) {
        dataProvider.locationResult = model
    }
}

extension KYCAddressController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchDelegate?.onStart()
        scrollView.setContentOffset(.zero, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let value = searchBar.text as NSString? {
            let current = value.replacingCharacters(in: range, with: text)
            searchDelegate?.onSearchRequest(current)
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let value = searchBar.text {
            searchDelegate?.onSearchRequest(value)
        }
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchDelegate?.onSearchViewCancel()
        searchBar.text = nil
    }
}

extension KYCAddressController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        validationFields.forEach({$0.resignFocus()})
    }
}
