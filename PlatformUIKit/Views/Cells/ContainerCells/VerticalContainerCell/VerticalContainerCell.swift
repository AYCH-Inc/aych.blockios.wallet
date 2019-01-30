//
//  VerticalContainerCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class VerticalContainerCell: NestedCollectionViewCell, Container {
    
    // MARK: Public IBOutlets
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var title: UILabel!
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var titleToCollectionConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var topToTitleConstraint: NSLayoutConstraint!
    
    // MARK: Public Properties
    
    weak var delegate: ContainerDelegate?
    var containerModel: StandardContainerModel!
    var layoutAttributes: LayoutAttributes = .vertical
    
    // MARK: Private Properties
    
    fileprivate var reuseIdentifiers: Set<String> = []
    
    // MARK: Constants
    
    fileprivate static let titleVerticalPadding: CGFloat = 16.0
    fileprivate static let titleToCollectionView: CGFloat = 16.0
    
    // MARK: Lifecycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.backgroundColor = nil
        collectionView.isMultipleTouchEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        title.font = BaseCell.sectionTitleFont()
        title.textColor = BaseCell.sectionTitleColor()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        containerModel = nil
        collectionView.reloadData()
    }
    
    // MARK: Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        updateLayoutAttributes()
        
        if needsReloadOnNextLayout {
            needsReloadOnNextLayout = false
            collectionView.reloadData()
        }
        
        guard containerModel != nil else { return }
        guard let collection = collectionView else { return }
        collection.backgroundColor = containerModel.backgroundColor
    }
    
    open func updateLayoutAttributes() {
        
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
        leadingConstraint.constant = layoutAttributes.sectionInsets.left
    }
    
    // MARK: Public Methods
    
    override public func configure(_ model: ContainerModel) {
        guard case .standard(let containerModel) = model else { return }
        
        self.containerModel = containerModel
        
        backgroundColor = containerModel.backgroundColor
        
        containerModel.cells.forEach { cell in
            let reuse = cell.reuseIdentifier()
            if !reuseIdentifiers.contains(reuse) {
                let nib = UINib(nibName: reuse, bundle: Bundle(for: cell.cellType()))
                collectionView.register(nib, forCellWithReuseIdentifier: reuse)
                reuseIdentifiers.insert(reuse)
            }
        }
        
        title.text = containerModel.title
        
        if containerModel.title == nil {
            titleToCollectionConstraint.constant = 0.0
            topToTitleConstraint.constant = 0.0
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        applyAccessibility()
    }
    
    // MARK: Class Methods
    
    class func maxCellHeightForModel(_ model: StandardContainerModel, itemWidth: CGFloat) -> CGFloat {
        var maxCellHeight: CGFloat = 0
        
        model.cells.forEach { cell in
            let cellType = cell.cellType()
            let height = cellType.heightForProposedWidth(itemWidth, model: cell)
            
            if height > maxCellHeight {
                maxCellHeight = height
            }
        }
        
        return maxCellHeight
    }
    
    class func totalCellHeightForModel(_ model: StandardContainerModel, itemWidth: CGFloat) -> CGFloat {
        
        let totalHeight = model.cells.map { (cellModel) -> CGFloat in
            return cellModel.heightForProposed(width: itemWidth)
            }.reduce(0, +)
        
        return totalHeight
    }
    
    override public class func heightForProposedWidth(_ width: CGFloat, containerModel: ContainerModel) -> CGFloat {
        guard case .standard(let model) = containerModel else { return 0.0 }
        
        let columns : CGFloat = model.layout.columns
        let layoutAttributes: LayoutAttributes = .vertical
        let rows = ceil(CGFloat(model.cells.count) / columns)
        let itemWidth = UICollectionViewCell.itemWidthFor(width, layoutAttributes: layoutAttributes, columns: columns)
        var titleHeight: CGFloat = 0
        var titleToCollection: CGFloat = 0
        
        if let titleText = model.title {
            titleHeight = NSAttributedString(
                string: titleText,
                attributes: [.font: sectionTitleFont()]
                ).height
            titleToCollection = titleToCollectionView + titleVerticalPadding
        }
        
        let totalCellHeight = totalCellHeightForModel(model, itemWidth: itemWidth)
        let maxCellHeight = maxCellHeightForModel(model, itemWidth: itemWidth)
        
        let cellHeightValue: CGFloat = columns > 1 ? maxCellHeight : totalCellHeight
        
        let singleColumnCollectionViewHeight = cellHeightValue + (rows * layoutAttributes.minimumInterItemSpacing)
        let multiColumnCollectionViewHeight = cellHeightValue * rows + ((rows - 1) * layoutAttributes.minimumInterItemSpacing)
        let collectionViewHeight = columns > 1 ? multiColumnCollectionViewHeight : singleColumnCollectionViewHeight
        
        return titleHeight + titleToCollection + collectionViewHeight + layoutAttributes.sectionInsets.top + layoutAttributes.sectionInsets.bottom
    }
}

extension VerticalContainerCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard containerModel != nil else { return UICollectionViewCell() }
        guard containerModel.cells.count > 0 else { return UICollectionViewCell() }
        let item = containerModel.cells[indexPath.row]
        let reuse = item.reuseIdentifier()
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuse,
            for: indexPath) as? BaseCell else {
                return UICollectionViewCell()
        }
        
        item.configure(cell)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard containerModel != nil else { return 0 }
        return containerModel.cells.count
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension VerticalContainerCell: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        guard containerModel != nil else { return .zero }
        
        let columns = containerModel.layout.columns
        
        let width = UICollectionViewCell.itemWidthFor(
            bounds.width,
            layoutAttributes: layoutAttributes,
            columns: columns
        )
        let itemModel = containerModel.cells[indexPath.row]
        let maxCellHeight = VerticalContainerCell.maxCellHeightForModel(
            containerModel,
            itemWidth: width
        )
        let cellType = itemModel.cellType()
        let trueCellHeight = cellType.heightForProposedWidth(width, model: itemModel)
        let height = columns > 1 ? maxCellHeight : trueCellHeight
        
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.container(self, didSelectItemAt: indexPath)
    }
    
}
