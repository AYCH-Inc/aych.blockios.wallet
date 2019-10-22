//
//  AutoPairingViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

/// The screen responsible for auto pairing
final class AutoPairingViewController: UIViewController {

    // MARK: - Properties
    
    private let presenter: AutoPairingScreenPresenter
    private var viewFinderViewController: UIViewController!
    
    // MARK: - Setup
    
    init(presenter: AutoPairingScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: AutoPairingViewController.objectName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewFinderViewController = presenter.scannerBuilder.build()!
        viewFinderViewController.view.frame = UIScreen.main.bounds
        add(child: viewFinderViewController)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewFinderViewController.remove()
    }
}
