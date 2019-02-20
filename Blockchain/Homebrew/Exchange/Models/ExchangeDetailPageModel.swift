//
//  ExchangeDetailPageModel.swift
//  Blockchain
//
//  Created by AlexM on 2/13/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

enum ExchangeHeader {
    case detail(ExchangeDetailHeaderModel)
    case locked(ExchangeDetailHeaderModel)
}

extension ExchangeHeader {
    
    func configure(_ view: ExchangeHeaderView) {
        view.configure(with: self)
    }
    
    var headerType: ExchangeHeaderView.Type {
        switch self {
        case .detail:
            return ExchangeDetailHeaderView.self
        case .locked:
            return ExchangeLockedHeaderView.self
        }
    }
    
    var reuseIdentifier: String {
        switch self {
        case .detail:
            return ExchangeDetailHeaderView.identifier
        case .locked:
            return ExchangeLockedHeaderView.identifier
        }
    }
    
    func heightForProposed(width: CGFloat) -> CGFloat {
        return headerType.heightForProposedWidth(width, model: self)
    }
}

struct ExchangeDetailPageModel {
    
    enum PageType {
        case confirm(OrderTransaction, Conversion)
        case locked(OrderTransaction, Conversion)
        case overview(ExchangeTradeModel)
    }
    
    let pageType: PageType
    var footer: ActionableFooterModel?
    var cells: [ExchangeCellModel]?
    var header: ExchangeHeader?
    var alertModel: AlertModel?
    
    init(
        type: PageType,
        footer: ActionableFooterModel? = nil,
        cells: [ExchangeCellModel]? = nil,
        header: ExchangeHeader? = nil,
        alertModel: AlertModel? = nil
        ) {
        self.pageType = type
        self.footer = footer
        self.cells = cells
        self.header = header
        self.alertModel = alertModel
        if alertModel != nil, case .locked = type {
            assertionFailure("The trade locked page should not have an alertModel to present.")
        }
        if header != nil, case .confirm = type {
            assertionFailure("The trade confirmation page shouldn't have a header view.")
        }
    }
}

extension ExchangeDetailPageModel.PageType {
    
    var analyticsIdentifier: String {
        switch self {
        case .confirm:
            return "exchange_detail_confirm"
        case .locked:
            return "exchange_detail_locked"
        case .overview:
            return "exchange_detail_overview"
        }
    }
}
