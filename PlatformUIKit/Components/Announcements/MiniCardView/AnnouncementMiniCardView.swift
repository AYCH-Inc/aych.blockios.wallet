//
//  AnnouncementMiniCardView.swift
//  PlatformUIKit
//
//  Created by Jack on 28/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import PlatformKit

public final class AnnouncementMiniCardView: UIView, AnnoucementCardViewConforming {
    
    // MARK: - Subviews
    
    private var backgroundImageView: UIImageView!
    private var thumbImageView: UIImageView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var disclosureIndicatorImageView: UIImageView!
    private var bottomSeparatorView: UIView!
    
    // MARK: - Private properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let viewModel: AnnouncementCardViewModel
    
    // MARK: - Init
    
    public init(using viewModel: AnnouncementCardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) is not implemented")
    }
    
    // MARK: - View Lifecycle
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        viewModel.didAppear()
    }
    
    // MARK: - Private methods
    
    @objc private func onTap(_ sender: UITapGestureRecognizer) {
        if let button = viewModel.buttons.first {
            button.tapRelay.accept(())
        }
    }

    private func setup() {
        
        // Initialisation
        
        backgroundImageView = UIImageView()
        thumbImageView = UIImageView()
        titleLabel = UILabel()
        descriptionLabel = UILabel()
        disclosureIndicatorImageView = UIImageView()
        bottomSeparatorView = UIView()
        
        // Configuration
        
        clipsToBounds = true
        backgroundColor = viewModel.background.color
        
        backgroundImageView.image = viewModel.background.image
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        thumbImageView.image = UIImage(named: viewModel.image.name)
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.layoutSize(to: viewModel.image.size)
        
        titleLabel.font = UIFont.mainMedium(16.0)
        titleLabel.text = viewModel.title
        titleLabel.textColor = .titleText
        
        descriptionLabel.font = UIFont.mainMedium(12.0)
        descriptionLabel.text = viewModel.description
        descriptionLabel.textColor = .descriptionText
        
        disclosureIndicatorImageView.image = #imageLiteral(resourceName: "chevron_right").withRenderingMode(.alwaysTemplate)
        disclosureIndicatorImageView.tintColor = .grey800
        
        bottomSeparatorView.backgroundColor = .mediumBorder
        
        setupAccessibility()
        
        // Layout
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundImageView)
        
        let textStackView = UIStackView(
            arrangedSubviews: [
                titleLabel,
                descriptionLabel
            ]
        )
        textStackView.axis = .vertical
        textStackView.distribution = .fill
        textStackView.alignment = .leading
        textStackView.spacing = 4.0
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(
            arrangedSubviews: [
                thumbImageView,
                textStackView
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if viewModel.hasMiniCardAction {
            stackView.insertArrangedSubview(
                disclosureIndicatorImageView,
                at: stackView.arrangedSubviews.count
            )
            stackView.setCustomSpacing(24.0, after: disclosureIndicatorImageView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
            addGestureRecognizer(tapGesture)
        }
        
        addSubview(stackView)
        
        addSubview(bottomSeparatorView)
        
        textStackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 64.0)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.0),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.0)
        ])
        
        thumbImageView.setContentHuggingPriority(.required, for: .vertical)
        thumbImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        thumbImageView.setContentHuggingPriority(.required, for: .horizontal)
        thumbImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        let thumbImageViewSize = CGSize(width: 24.0, height: 32.0)
        NSLayoutConstraint.activate([
            thumbImageView.widthAnchor.constraint(equalToConstant: thumbImageViewSize.width),
            thumbImageView.heightAnchor.constraint(equalToConstant: thumbImageViewSize.height)
        ])
        
        disclosureIndicatorImageView.setContentHuggingPriority(.required, for: .vertical)
        disclosureIndicatorImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        disclosureIndicatorImageView.setContentHuggingPriority(.required, for: .horizontal)
        disclosureIndicatorImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        let disclosureIndicatorImageViewSize = CGSize(width: 8.0, height: 12.0)
        NSLayoutConstraint.activate([
            disclosureIndicatorImageView.widthAnchor.constraint(equalToConstant: disclosureIndicatorImageViewSize.width),
            disclosureIndicatorImageView.heightAnchor.constraint(equalToConstant: disclosureIndicatorImageViewSize.height)
        ])
        
    }
    
    private func setupAccessibility() {
        typealias Identifier = Accessibility.Identifier.Dashboard.Announcement
        titleLabel.accessibility = .init(id: .value(Identifier.titleLabel))
        descriptionLabel.accessibility = .init(id: .value(Identifier.descriptionLabel))
        thumbImageView.accessibility = .init(id: .value(Identifier.imageView))
    }
}
