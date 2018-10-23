//
//  TransactionTableCell+ViewModel.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension TransactionTableCell {

    func configure(with viewModel: TransactionDetailViewModel) {
        setActionLabelText("sent")
        setDateLabelText(viewModel.dateString)
        setButtonText(viewModel.amountString)
        setInfoType(TransactionInfoTypeDefault)
    }

    func showViewModelDetail() {
        
    }
}
