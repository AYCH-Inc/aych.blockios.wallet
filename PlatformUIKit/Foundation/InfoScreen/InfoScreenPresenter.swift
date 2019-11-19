//
//  InfoScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

/// Raw content for into screen.
/// Should be implemented by a concrete type
public protocol InfoScreenContent {
    var image: String { get }
    var title: String { get }
    var description: String { get }
    var disclaimerInputs: [InteractableTextViewModel.Input] { get }
    var buttonTitle: String { get }
}

public struct InfoScreenPresenter {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.InfoScreen
    
    // MARK: - Properties
    
    let imageViewContent: ImageViewContent
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    public let disclaimerViewModel: InteractableTextViewModel
    let buttonViewModel: ButtonViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(with content: InfoScreenContent, action: @escaping () -> Void) {
        imageViewContent = .init(
            image: UIImage(named: content.image),
            accessibility: .id(AccessibilityId.imageView)
        )
        titleLabelContent = .init(
            text: content.title,
            font: .mainSemibold(20),
            color: .titleText,
            accessibility: .id(AccessibilityId.titleLabel)
        )
        descriptionLabelContent = .init(
            text: content.description,
            font: .mainMedium(16),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
        let disclaimerFont = UIFont.mainMedium(12)
        disclaimerViewModel = InteractableTextViewModel(
            inputs: content.disclaimerInputs,
            textStyle: .init(color: .descriptionText, font: disclaimerFont),
            linkStyle: .init(color: .linkableText, font: disclaimerFont),
            alignment: .center
        )
        buttonViewModel = .primary(
            with: content.buttonTitle,
            cornerRadius: 8
        )
        buttonViewModel.tapRelay
            .bind { action() }
            .disposed(by: disposeBag)
    }
}
