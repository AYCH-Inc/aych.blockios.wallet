//
//  BaseViewController.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public class BaseViewController: UIViewController {
    
    // MARK: Public IBOutlets
    
    @IBOutlet var outerCollectionView: UICollectionView?
    @IBOutlet var layout: UICollectionViewFlowLayout?
    
    // MARK: Private Properties
    
    fileprivate var reuseIdentifiers: Set<String> = []
    fileprivate var internalModel: InternalModel!
    
    struct InternalModel {
        var containers: [ContainerModel]?
        var numberOfItems: Int {
            return containers?.count ?? 0
        }
    }
    
    // MARK: Factory
    
    public static func make() -> BaseViewController {
        let storyboard = UIStoryboard(name: String(describing: BaseViewController.self), bundle: Bundle(for: BaseViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! BaseViewController
        return controller
    }
    
    // MARK: Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let layoutAttributes = LayoutAttributes.outer
        
        layout?.sectionInset = layoutAttributes.sectionInsets
        layout?.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout?.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
        
        /// Accessibility
        isAccessibilityElement = false
        outerCollectionView?.isAccessibilityElement = false
        outerCollectionView?.shouldGroupAccessibilityChildren = true
        outerCollectionView?.delegate = self
        outerCollectionView?.dataSource = self
        
        registerAllCellTypes()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        guard let collection = outerCollectionView else { return }
        guard let containers = internalModel.containers else { return }
        let indexPaths : [IndexPath] = containers.enumerated().map({ return IndexPath(item: $0.offset, section: 0)})
        let cells = indexPaths.map({ return collection.cellForItem(at: $0)})
        cells.forEach { container in
            if let cell = container as? NestedCollectionViewCell {
                cell.needsReloadOnNextLayout = true
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: Public
    
    public func apply(_ models: [ContainerModel]?) {
        internalModel = InternalModel(containers: models)
        guard outerCollectionView != nil else { return }
        registerAllCellTypes()
        outerCollectionView?.reloadData()
    }
    
    // MARK: Private
    
    fileprivate func registerAllCellTypes() {
        guard let collectionView = outerCollectionView else {
            assertionFailure("expected to have a collectionView at this point")
            return
        }
        
        guard let containers = internalModel.containers else { return }
        
        for section in 0 ..< collectionView.numberOfSections {
            for (item, model) in containers.enumerated() {
                let reuse = model.reuseIdentifier()
                
                let collectionReuseIdentifier = "\(reuse)-\(section)-\(item)"
                
                if !reuseIdentifiers.contains(collectionReuseIdentifier) {
                    let nib = UINib.init(nibName: reuse, bundle: Bundle(for: model.cellType()))
                    collectionView.register(nib, forCellWithReuseIdentifier: collectionReuseIdentifier)
                    reuseIdentifiers.insert(reuse)
                }
            }
        }
    }
}

extension BaseViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let containers = internalModel.containers else { return UICollectionViewCell() }
        
        let model = containers[indexPath.row]
        let reuse = model.reuseIdentifier()
        let collectionReuseIdentifier = "\(reuse)-\(indexPath.section)-\(indexPath.row)"
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: collectionReuseIdentifier,
            for: indexPath) as? BaseCell else { return UICollectionViewCell() }
        
        if var container = cell as? Container {
            container.delegate = self
        }
        
        cell.configure(model)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return internalModel.numberOfItems
    }
}

extension BaseViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width
        guard let containers = internalModel.containers else { return .zero }
        let containerModel = containers[indexPath.row]
        
        let height = containerModel.heightForProposed(
            width: width,
            indexPath: indexPath
        )
        
        let size = CGSize(width: collectionView.bounds.size.width, height: height)
        
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let nestedCell = cell as? NestedCollectionViewCell {
            nestedCell.needsReloadOnNextLayout = true
        }
    }
}

extension BaseViewController: ContainerDelegate {
    public func container(_ container: UICollectionViewCell, didSelectItemAt indexPath: IndexPath) {
        
    }
}
