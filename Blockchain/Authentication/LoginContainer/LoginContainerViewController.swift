//
//  LoginContainerViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// A container for `AddressViewController`s and `PinScreenViewController` instances
class LoginContainerViewController: UIViewController {

    // MARK: Types
    
    enum Input {
        case view(UIView)
        case viewController(UIViewController)
        
        var view: UIView {
            switch self {
            case .view(let view):
                return view
            case .viewController(let viewController):
                return viewController.view
            }
        }
        
        var viewController: UIViewController? {
            switch self {
            case .viewController(let vc):
                return vc
            case .view:
                return nil
            }
        }
    }
    
    /// The flow layout of the collection view
    private class CollectionViewFlowLayout: UICollectionViewFlowLayout {
        override init() {
            super.init()
            itemSize = UIScreen.main.bounds.size
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            scrollDirection = .horizontal
        }
    
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // MARK: - Properties
    
    private lazy var collectionViewFlowLayout = CollectionViewFlowLayout()
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var pageControl: UIPageControl!
    
    private var isPageControlCurrentlyInteracted = false
    
    private let inputs: [Input]
    private let translationAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    // MARK: - Lifecycle
    
    init(using inputs: [Input]) {
        self.inputs = inputs
        super.init(nibName: LoginContainerViewController.className, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = collectionViewFlowLayout
        collectionView.delegate = self
        collectionView.register(UINib(nibName: LoginContainerCollectionViewCell.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: LoginContainerCollectionViewCell.className)
        pageControl.pageIndicatorTintColor = .addressPageIndicator
        pageControl.currentPageIndicatorTintColor = .tertiary
        pageControl.currentPage = 0
        pageControl.numberOfPages = inputs.count - 1
        pageControl.alpha = 0
        pageControl.accessibilityIdentifier = AccessibilityIdentifiers.Address.pageControl
        
        // TODO: Remove availability check when upgrading to iOS 11
        if #available(iOS 11, *) {
            translationAnimator.pausesOnCompletion = true
        }
        
        view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewFlowLayout.itemSize = CGSize(width: view.bounds.width,
                                                   height: pageControl.frame.minY - view.layoutMargins.top)
        collectionViewFlowLayout.invalidateLayout()
    }
    
    private func didFinishScrolling() {
        let isNavigationEnabled = collectionView.contentOffset.x == 0
        navigationItem.leftBarButtonItem?.isEnabled = isNavigationEnabled
        navigationItem.rightBarButtonItem?.isEnabled = isNavigationEnabled
        isPageControlCurrentlyInteracted = false
    }
    
    private func setStatusBarStateIfNeeded() {
        let current = UIApplication.shared.statusBarStyle
        let next: UIStatusBarStyle = currentItemIndex == 0 ? .lightContent : .default
        guard next != current else { return }
        UIApplication.shared.statusBarStyle = next
    }
    
    /// Returns the currently displayed item index
    private var currentItemIndex: Int {
        let offset = collectionView.contentOffset.x + collectionView.bounds.width * 0.5
        let index = Int(offset / collectionView.contentSize.width * CGFloat(inputs.count))
        return index
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension LoginContainerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return inputs.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoginContainerCollectionViewCell.className,
                                                      for: indexPath) as! LoginContainerCollectionViewCell
        
        let input = inputs[indexPath.row]
        if let viewController = input.viewController {
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
        cell.input = input
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension LoginContainerViewController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        var firstTouch = true
        translationAnimator.addAnimations { [weak self] in
            guard let self = self else { return }
            guard firstTouch else {
                return
            }
            firstTouch = false
            self.view.backgroundColor = .white
            self.pageControl.alpha = 1
            self.navigationItem.titleView?.alpha = 0
            self.navigationItem.leftBarButtonItem?.tintColor = .clear
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didFinishScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        didFinishScrolling()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let visibleRect = scrollView.bounds
        let expectedRect = CGRect(x: CGFloat(pageControl.currentPage + 1) * scrollView.contentOffset.x,
                                  y: scrollView.bounds.minY,
                                  width: scrollView.bounds.width,
                                  height: scrollView.bounds.height)
        guard visibleRect == expectedRect else { return }
        didFinishScrolling()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.bounds.width
        let normalizedOffset = max(min(scrollView.contentOffset.x, maxOffset), 0)
        
        // TODO: This is a trick, meant to prevent the animator to complete, thus reaching `inactive` state.
        // Once we upgrade to iOS 11, we will be able to remove this `min` check
        // as the animator's `pausesOnCompletion` equals `true`.
        let fraction = min(normalizedOffset / maxOffset, 0.99)
        translationAnimator.fractionComplete = fraction
        
        if !isPageControlCurrentlyInteracted && scrollView.contentSize.width > 0 {
            let offset = scrollView.contentOffset.x - scrollView.bounds.width * 0.5
            let page = Int(offset / scrollView.contentSize.width * CGFloat(inputs.count))
            pageControl.currentPage = max(page, 0)
        }
        
        setStatusBarStateIfNeeded()
    }
}

// MARK: - User Actions

extension LoginContainerViewController {
    @IBAction private func didSelectPage(pageControl: UIPageControl) {
        isPageControlCurrentlyInteracted = true
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
