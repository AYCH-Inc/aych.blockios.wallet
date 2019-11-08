//
//  InfoScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public final class InfoScreenViewController: BaseScreenViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var noteLabel: UILabel!
    @IBOutlet private var buttonView: ButtonView!

    // MARK: - Injected
    
    private let presenter: InfoScreenPresenter
    
    // MARK: - Lifecycle
    
    public init(presenter: InfoScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: InfoScreenViewController.objectName, bundle: Self.bundle)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: .darkContent(ignoresStatusBar: false, background: .clear),
            leadingButtonStyle: .close)
        thumbImageView.content = presenter.imageViewContent
        titleLabel.content = presenter.titleLabelContent
        descriptionLabel.content = presenter.descriptionLabelContent
        noteLabel.content = presenter.noteLabelContent
        buttonView.viewModel = presenter.buttonViewModel
    }
}
