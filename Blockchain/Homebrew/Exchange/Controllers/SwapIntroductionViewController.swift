//
//  SwapIntroductionViewController.swift
//  Blockchain
//
//  Created by AlexM on 7/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

class SwapIntroductionViewController: UIViewController {
    
    // MARK: Private Model
    
    struct Item {
        let image: UIImage
        let title: String
        let subtitle: String
    }
    
    var start: (() -> Void)?
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var getStartedButton: UIButton!
    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var layout: FadeInOutFlowLayout!
    
    private let reuseIdentifier = String(describing: SwapIntroductionCollectionViewCell.self)
    private let feedback: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private let layoutAttributes: LayoutAttributes = .outer
    private lazy var items: [Item] = {
        return Item.tutorial
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.invalidateLayout()
        
        title = LocalizationConstants.Swap.swap
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            UINib(nibName: reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: reuseIdentifier
        )
        collectionView.decelerationRate = .fast
        pageControl.accessibilityIdentifier = AccessibilityIdentifiers.Address.pageControl
        pageControl.currentPage = 0
        pageControl.numberOfPages = items.count
        
        getStartedButton.layer.cornerRadius = 4.0
        getStartedButton.accessibilityLabel = AccessibilityIdentifiers.SwapIntroduction.startNow
    }
    
    private func setupLayoutAttributes() {
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
    }
    
    // MARK: Actions
    
    @IBAction func getStartedTapped(_ sender: UIButton) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        start?()
    }
    
}

extension SwapIntroductionViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath) as? SwapIntroductionCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard indexPath.row < items.count else { return UICollectionViewCell() }
        
        let model = items[indexPath.row]
        cell.apply(image: model.image, title: model.title, subtitle: model.subtitle)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension SwapIntroductionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // no-op
    }
}

// MARK: UIScrollViewDelegate

extension SwapIntroductionViewController {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        pageControl.currentPage = index
        feedback.prepare()
        feedback.selectionChanged()
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let visible = collectionView.visibleCells.first {
            let insets: CGFloat = layout.sectionInset.left
            let point = CGPoint(x: targetContentOffset.pointee.x + insets, y: visible.frame.origin.y)
            
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
            guard let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
            if point.x > layoutAttributes.frame.origin.x + layoutAttributes.frame.width / 2 {
                let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                if let layoutAttributes = collectionView.layoutAttributesForItem(at: nextIndexPath) {
                    targetContentOffset.pointee.x = layoutAttributes.frame.origin.x - insets
                }
            } else {
                targetContentOffset.pointee.x = layoutAttributes.frame.origin.x - insets
            }
        }
    }
}

extension SwapIntroductionViewController: NavigatableView {
    
    var rightNavControllerCTAType: NavigationCTAType {
        return .none
    }
    
    var leftNavControllerCTAType: NavigationCTAType {
        return .menu
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        AppCoordinator.shared.toggleSideMenu()
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        // no op
    }
}

extension SwapIntroductionViewController.Item {
    static let images = [#imageLiteral(resourceName: "swap-welcome-1"), #imageLiteral(resourceName: "swap-welcome-2"), #imageLiteral(resourceName: "swap-welcome-3"), #imageLiteral(resourceName: "swap-welcome-4"), #imageLiteral(resourceName: "swap-welcome-5")]
    private static let tutorialStringValues = LocalizationConstants.Swap.Tutorial.self
    static let tutorial: [SwapIntroductionViewController.Item] = [
        .init(image: #imageLiteral(resourceName: "swap-welcome-1"), title: tutorialStringValues.PageOne.title, subtitle: tutorialStringValues.PageOne.subtitle),
        .init(image: #imageLiteral(resourceName: "swap-welcome-2"), title: tutorialStringValues.PageTwo.title, subtitle: tutorialStringValues.PageTwo.subtitle),
        .init(image: #imageLiteral(resourceName: "swap-welcome-3"), title: tutorialStringValues.PageThree.title, subtitle: tutorialStringValues.PageThree.subtitle),
        .init(image: #imageLiteral(resourceName: "swap-welcome-4"), title: tutorialStringValues.PageFour.title, subtitle: tutorialStringValues.PageFour.subtitle),
        .init(image: #imageLiteral(resourceName: "swap-welcome-5"), title: tutorialStringValues.PageFive.title, subtitle: tutorialStringValues.PageFive.subtitle)
    ]
}
