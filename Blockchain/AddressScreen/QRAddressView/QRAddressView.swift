//
//  QRAddressView.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxCocoa

/// Crypto address represented as QR image and address text
final class QRAddressView: UIView {
    
    // MARK: - UI Properties
    
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var qrImageView: UIImageView!
    @IBOutlet private var separatorView: UIView!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var button: UIButton!

    // MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    var viewModel: QRAddressViewModel! {
        didSet {
            addressLabel.accessibility = viewModel.addressLabelAccessibility
            qrImageView.accessibility = viewModel.addressImageViewAccessibility
            button.accessibility = viewModel.copyButtonAcessibility
            
            // Bind status to the the display
            viewModel.status
                .bind { [weak self] status in
                    self?.setup(for: status)
                }
                .disposed(by: disposeBag)
            
            // Bind taps to the view model
            button.rx.tap
                .bind(to: viewModel.tapRelay)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        fromNib()
        let borderColor = UIColor.mediumBorder
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = 4
        separatorView.backgroundColor = borderColor
        activityIndicatorView.color = .primary
        statusLabel.textColor = .primary
    }
    
    // Setups the UI according to a given display status
    private func setup(for status: DisplayAddressStatus) {
        let contentVisibility: Visibility
        switch status {
        case .readyForDisplay(content: let content):
            contentVisibility = .visible
            qrImageView.image = content.image
            addressLabel.text = content.string
            activityIndicatorView.stopAnimating()
        case .awaitingFetch, .fetching:
            contentVisibility = .hidden
            statusLabel.text = LocalizationConstants.Address.creatingStatusLabel
            activityIndicatorView.startAnimating()
        case .fetchFailure(localizedReason: let reason):
            contentVisibility = .hidden
            statusLabel.text = reason
            activityIndicatorView.stopAnimating()
        }
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState],
                       animations: {
                        self.qrImageView.alpha = contentVisibility.defaultAlpha
                        self.addressLabel.alpha = contentVisibility.defaultAlpha
                        self.separatorView.alpha = contentVisibility.defaultAlpha
                        self.statusLabel.alpha = contentVisibility.invertedAlpha
        }, completion: nil)
    }
    
    // MARK: - User Actions
    
    @IBAction private func touchDown() {
        animateTouch(scale: 0.95)
    }
    
    @IBAction private func touchUp() {
        animateTouch(scale: 1)
    }
    
    private func animateTouch(scale: CGFloat) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
}
