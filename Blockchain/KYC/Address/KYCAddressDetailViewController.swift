//
//  KYCAddressDetailViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCAddressDetailViewController: UIViewController {

    struct PageModel {
        let cellModels: [CellModel]
        let address: PostalAddress
    }

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var tableView: UITableView!

    // MARK: Private Properties

    fileprivate var model: PageModel!
    fileprivate var reuseIdentifiers: Set<String> = []

    // MARK: Class Functions

    static func make(_ address: PostalAddress) -> KYCAddressDetailViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! KYCAddressDetailViewController
        let model = PageModel(
            cellModels: address.generateCellModels(),
            address: address
        )
        controller.model = model
        return controller
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerAllCellTypes()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }

    fileprivate func registerAllCellTypes() {
        model.cellModels.forEach { (model) in
            let reuse = model.cellType().identifier
            if !reuseIdentifiers.contains(reuse) {
                let nib = UINib.init(nibName: reuse, bundle: Bundle(for: model.cellType()))
                tableView.register(nib, forCellReuseIdentifier: reuse)
                reuseIdentifiers.insert(reuse)
            }
        }
    }
}

extension KYCAddressDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = model.cellModels[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.cellType().identifier, for: indexPath) as? BaseTableViewCell else { return UITableViewCell() }
        cell.configure(with: cellModel)
        if let textEntry = cell as? TextEntryCell {
            textEntry.delegate = self
        }
        cell.separatorInset = UIEdgeInsets(
            top: 0.0,
            left: 8.0,
            bottom: 0.0,
            right: 8.0
        )
        return cell
    }
}

extension KYCAddressDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = model.cellModels[indexPath.item]
        return cellModel.heightForProposed(width: tableView.bounds.width)
    }
}

extension KYCAddressDetailViewController: TextEntryCellDelegate {
    func textEntryCell(_ cell: TextEntryCell, enteredValue value: String) {
        print(value)
    }
}
