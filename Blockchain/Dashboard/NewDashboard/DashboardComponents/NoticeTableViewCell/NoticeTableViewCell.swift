//
//  NoticeTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class NoticeTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var viewModel: NoticeViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            noticeView.viewModel = viewModel
        }
    }
        
    private let noticeView = NoticeView()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(noticeView)
        noticeView.layoutToSuperview(axis: .horizontal, offset: 24)
        noticeView.layoutToSuperview(axis: .vertical, offset: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}
