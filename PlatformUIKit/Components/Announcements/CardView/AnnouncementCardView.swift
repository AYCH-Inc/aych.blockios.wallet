//
//  AnnouncementCardView.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public protocol AnnoucementCardViewConforming: UIView {}

public final class AnnouncementCardView: UIView, AnnoucementCardViewConforming {
    
    // MARK: - UI Properties
    
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var dismissButton: UIButton!
    @IBOutlet private var buttonsStackView: UIStackView!
    @IBOutlet private var buttonPlaceholderSeparatorView: UIView!
    
    @IBOutlet private var bottomSeparatorView: UIView!
    
    @IBOutlet private var titleToImageConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewToBottomConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let viewModel: AnnouncementCardViewModel
    
    // MARK: - Setup
    
    public init(using viewModel: AnnouncementCardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) is not implemented")
    }
    
    private func setup() {
        fromNib()
        backgroundColor = viewModel.background.color
        backgroundImageView.image = viewModel.background.image
        thumbImageView.image = UIImage(named: viewModel.image.name)
        thumbImageView.layout(size: viewModel.image.size)
        titleLabel.text = viewModel.title
        titleLabel.textColor = .titleText
        descriptionLabel.text = viewModel.description
        descriptionLabel.textColor = .descriptionText
        bottomSeparatorView.backgroundColor = .mediumBorder
        setupButtons()
        fixPositions()
        setupAccessibility()
        viewModel.didAppear()
    }
    
    private func setupAccessibility() {
        typealias Identifier = Accessibility.Identifier.Dashboard.Announcement
        titleLabel.accessibility = .init(id: .value(Identifier.titleLabel))
        descriptionLabel.accessibility = .init(id: .value(Identifier.descriptionLabel))
        thumbImageView.accessibility = .init(id: .value(Identifier.imageView))
        dismissButton.accessibility = .init(id: .value(Identifier.dismissButton))
    }
    
    private func setupButtons() {
        dismissButton.isHidden = viewModel.isDismissButtonHidden
        dismissButton.rx.tap
            .bind(to: viewModel.dismissalRelay)
            .disposed(by: disposeBag)
        
        for buttonViewModel in viewModel.buttons {
            setupButton(for: buttonViewModel)
        }
    }
    
    private func setupButton(for viewModel: ButtonViewModel) {
        let button = ButtonView()
        button.viewModel = viewModel
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50)
            ])
        buttonsStackView.addArrangedSubview(button)
    }
    
    private func fixPositions() {
        if viewModel.title == nil {
            titleToImageConstraint.constant = 0
        }
        if viewModel.buttons.isEmpty {
            stackViewToBottomConstraint.constant = 0
        } else { // Remove placeholder view since there are actual buttons
            buttonPlaceholderSeparatorView.removeFromSuperview()
        }
    }
}
