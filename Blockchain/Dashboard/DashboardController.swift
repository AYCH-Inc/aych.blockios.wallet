//
//  DashboardController.swift
//  Blockchain
//
//  Created by Maurice A. on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import Charts

final class DashboardController: UIViewController {

    // MARK: - Properties

    // TICKET: IOS-???? - Refactor TabViewController to avoid Int32 conversion
    public enum DashboardTab: Int {
        case send, dashboard, transactions, receive
    }

    var assetType: LegacyAssetType? {
        didSet {
            reload()
        }
    }

    private static let horizontalPadding: CGFloat = 15
    private let priceChartPadding: CGFloat = 20
    private let previewViewSpacing: CGFloat = 16
    private let defaultContentHeight: CGFloat!
    private var priceChartContainerView: UIView
    private var bitcoinPricePreview, etherPricePreview, bitcoinCashPricePreview: BCPricePreviewView
    private var lastEthExchangeRate: NSDecimalNumber!
    private let wallet: Wallet, tabControllerManager: TabControllerManager

    // TICKET: IOS-???? - Move formatters to a global formatter pool (they are expensive objects)
    fileprivate lazy var numberFormatter: NumberFormatter = {
        return NumberFormatter()
    }()

    fileprivate lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()

    private lazy var chartContainerViewController: BCPriceChartContainerViewController = {
        let theViewController = BCPriceChartContainerViewController()
        theViewController.modalPresentationStyle = .overCurrentContext
        theViewController.delegate = self
        return theViewController
    }()

    private lazy var balancesLabelFrame = {
        return CGRect(
            x: DashboardController.horizontalPadding,
            y: 16,
            width: (view.frame.size.width / 2),
            height: 40
        )
    }()

    private lazy var balancesChartView: BCBalancesChartView = {
        let balancesChartViewFrame = CGRect(
            x: DashboardController.horizontalPadding,
            y: balancesLabelFrame.origin.y + balancesLabelFrame.size.height,
            width: view.frame.size.width - (DashboardController.horizontalPadding * 2),
            height: 320
        )
        let balancesChartView = BCBalancesChartView(frame: balancesChartViewFrame)
        balancesChartView.delegate = self
        balancesChartView.layer.masksToBounds = false
        balancesChartView.layer.cornerRadius = 2
        balancesChartView.layer.shadowOffset = CGSize(width: 0, height: 2)
        balancesChartView.layer.shadowRadius = 3
        balancesChartView.layer.shadowOpacity = 0.25
        return balancesChartView
    }()

    // MARK: - IBOutlets
    
    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        wallet = WalletManager.shared.wallet
        tabControllerManager = AppCoordinator.shared.tabControllerManager
        priceChartContainerView = UIView(frame: CGRect.zero)
        bitcoinPricePreview = BCPricePreviewView(frame: CGRect.zero, assetName: "", price: "", assetImage: "")
        etherPricePreview = BCPricePreviewView(frame: CGRect.zero, assetName: "", price: "", assetImage: "")
        bitcoinCashPricePreview = BCPricePreviewView(frame: CGRect.zero, assetName: "", price: "", assetImage: "")
        lastEthExchangeRate = NSDecimalNumber(value: 0)
        // = balancesChartHeight + titleLabelHeight + pricePreviewHeight + pricePreviewSpacing + bottomPadding;
//        let balancesChartHeight: CGFloat = 0
//        let titleLabelHeight: CGFloat = 0
        defaultContentHeight = 0
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
            selector: #selector(resetScrollView),
            name: .UIApplicationDidEnterBackground,
            object: nil
        )

        setupPieChart()

        setupPriceCharts()
    }

    private func reload() {
        guard let btcFiatBalance = getBtcBalance() else {
            Logger.shared.error("Failed to get BTC balance!")
            return
        }
        guard let ethFiatBalance = getEthBalance() else {
            Logger.shared.error("Failed to get ETH balance!")
            return
        }
        guard let bchFiatBalance = getBchBalance() else {
            Logger.shared.error("Failed to get BCH balance!")
            return
        }
        guard let watchOnlyFiatBalance = getBtcWatchOnlyBalance() else {
            Logger.shared.error("Failed to get BTC watch-only balance!")
            return
        }
        guard let latestMultiAddressResponse = WalletManager.shared.latestMultiAddressResponse,
            let symbolLocal = latestMultiAddressResponse.symbol_local,
            let symbol = symbolLocal.symbol else {
                Logger.shared.warning("Failed to get symbol from latestMultiAddressResponse!")
                return
        }

        let truncatedEthBalance = wallet.getEthBalanceTruncated()

        let bchBalance = wallet.getBchBalance()

        let totalActiveBalance = wallet.getTotalActiveBalance()

        let totalFiatBalance = btcFiatBalance + ethFiatBalance + bchFiatBalance

        let walletIsInitialized = wallet.isInitialized()

        if walletIsInitialized {
            balancesChartView.updateFiatSymbol(symbol)

            // Fiat balances
            balancesChartView.updateBitcoinFiatBalance(btcFiatBalance)
            balancesChartView.updateEtherFiatBalance(ethFiatBalance)
            balancesChartView.updateBitcoinCashFiatBalance(bchFiatBalance)
            balancesChartView.updateTotalFiatBalance(
                NumberFormatter.appendString(toFiatSymbol: NumberFormatter.fiatString(from: totalFiatBalance))
            )

            // Balances
            balancesChartView.updateBitcoinBalance(NumberFormatter.formatAmount(totalActiveBalance, localCurrency: false))
            balancesChartView.updateEtherBalance(truncatedEthBalance)
            balancesChartView.updateBitcoinCashBalance(NumberFormatter.formatAmount(bchBalance, localCurrency: false))

            // Watch-only balances
            let watchOnlyBalance = wallet.getWatchOnlyBalance()
            if watchOnlyBalance > 0 {
                balancesChartView.updateBitcoinWatchOnlyFiatBalance(watchOnlyFiatBalance)
                balancesChartView.updateBitcoinWatchOnlyBalance(NumberFormatter.formatAmount(watchOnlyBalance, localCurrency: false))

                // Increase height and Y positions to show watch only view
                balancesChartView.showWatchOnlyView()
                let offset = balancesChartView.frame.origin.y + balancesChartView.frame.size.height + previewViewSpacing
                priceChartContainerView.changeYPosition(offset)
                // [self.contentView changeHeight:self.defaultContentHeight + [self.balancesChartView watchOnlyViewHeight]];
            } else {
                // Show default heights and Y positions
                balancesChartView.hideWatchOnlyView()
                let offset = balancesChartView.frame.origin.y + balancesChartView.frame.size.height + previewViewSpacing
                priceChartContainerView.changeYPosition(offset)
                // [self.contentView changeHeight:self.defaultContentHeight];
            }
        }

        balancesChartView.updateChart()

        if !walletIsInitialized {
            balancesChartView.clearLegendKeyBalances()
        }

        reloadPricePreviews()

        reloadCards()
    }

    // TODO: replace with call to AnnouncementCard delegate
    private func reloadCards() {

    }

    private func reloadSymbols() {
        balancesChartView.updateWatchOnlyViewBalance()
    }

    private func fetchChartDataForAsset(asset: LegacyAssetType) {

    }

    private func updateEthExchangeRate(rate: NSDecimalNumber) {
        lastEthExchangeRate = rate
        // reloadPricePreviews()
    }

    private func showChartContainerViewController() {
        tabControllerManager.present(chartContainerViewController, animated: true)
    }

    @objc private func bitcoinChartTapped() {
        showChartContainerViewController()

        let priceChartViewFrame = CGRect(
            x: priceChartPadding,
            y: priceChartPadding,
            width: self.view.frame.size.width - priceChartPadding,
            height: (self.view.frame.size.height * (3/4)) - priceChartPadding
        )
        let priceChartView = BCPriceChartView(frame: priceChartViewFrame, assetType: .bitcoin, dataPoints: nil, delegate: self)
        chartContainerViewController.add(priceChartView, at: 0)
        fetchChartDataForAsset(asset: .bitcoin)
    }

    @objc private func etherChartTapped() {
        showChartContainerViewController()

        let priceChartViewFrame = CGRect(
            x: priceChartPadding,
            y: priceChartPadding,
            width: self.view.frame.size.width - priceChartPadding,
            height: (self.view.frame.size.height * (3/4)) - priceChartPadding
        )
        let priceChartView = BCPriceChartView(frame: priceChartViewFrame, assetType: .ether, dataPoints: nil, delegate: self)
        chartContainerViewController.add(priceChartView, at: 1)
        chartContainerViewController.updateEthExchangeRate(lastEthExchangeRate)
        fetchChartDataForAsset(asset: .ether)
    }

    @objc private func bitcoinCashChartTapped() {
        showChartContainerViewController()

        let priceChartViewFrame = CGRect(
            x: priceChartPadding,
            y: priceChartPadding,
            width: self.view.frame.size.width - priceChartPadding,
            height: (self.view.frame.size.height * (3/4)) - priceChartPadding
        )
        let priceChartView = BCPriceChartView(frame: priceChartViewFrame, assetType: .bitcoinCash, dataPoints: nil, delegate: self)
        chartContainerViewController.add(priceChartView, at: 2)
        fetchChartDataForAsset(asset: .bitcoinCash)
    }

    // MARK: - Charts

    // TICKET: IOS-???? - Refactor to use autolayout
    private func setupPieChart() {
        let balancesLabel = UILabel(frame: balancesLabelFrame)
        balancesLabel.textColor = .brandPrimary
        balancesLabel.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Large)
        balancesLabel.text = LocalizationConstants.balances.uppercased()

        // Replace view with the content view
        view.addSubview(balancesLabel)
        view.addSubview(balancesChartView)
    }

    // swiftlint:disable:next function_body_length
    private func setupPriceCharts() {
        let labelHeight: CGFloat = 40, previewViewHeight: CGFloat = 140
        let priceChartContainerViewFrame = CGRect(
            x: DashboardController.horizontalPadding,
            y: balancesChartView.frame.origin.y + balancesChartView.frame.size.height + previewViewSpacing,
            width: view.frame.size.width - (DashboardController.horizontalPadding * 2),
            height: labelHeight + (previewViewHeight * 3) + (previewViewSpacing * 2)
        )
        let priceChartContainerView = UIView(frame: priceChartContainerViewFrame)
        // Add to content view instead?
        view.addSubview(priceChartContainerView)

        let balancesLabelFrame = CGRect(x: 0, y: 0, width: (view.frame.size.width / 2), height: labelHeight)
        let balancesLabel = UILabel(frame: balancesLabelFrame)
        balancesLabel.textColor = .brandPrimary
        balancesLabel.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Large)
        balancesLabel.text = LocalizationConstants.Dashboard.priceCharts.uppercased()
        priceChartContainerView.addSubview(balancesLabel)

        let bitcoinPreviewViewFrame = CGRect(
            x: 0,
            y: balancesLabel.frame.origin.y + balancesLabel.frame.size.height,
            width: (view.frame.size.width - (DashboardController.horizontalPadding * 2)),
            height: previewViewHeight
        )
        let bitcoinPreviewView = BCPricePreviewView(
            frame: bitcoinPreviewViewFrame,
            assetName: AssetType.bitcoin.description,
            price: getBtcPrice() ?? "0",
            assetImage: "bitcoin_white"
        )
        priceChartContainerView.addSubview(bitcoinPreviewView)
        bitcoinPricePreview = bitcoinPreviewView

        let bitcoinChartTapGesture = UITapGestureRecognizer(target: self, action: #selector(bitcoinChartTapped))
        bitcoinPreviewView.addGestureRecognizer(bitcoinChartTapGesture)

        let etherPreviewViewFrame = CGRect(
            x: 0,
            y: bitcoinPreviewView.frame.origin.y + bitcoinPreviewView.frame.size.height + previewViewSpacing,
            width: (view.frame.size.width - (horizontalPadding * 2)),
            height: previewViewHeight
        )
        let etherPreviewView = BCPricePreviewView(
            frame: etherPreviewViewFrame,
            assetName: AssetType.ethereum.description,
            price: getEthPrice() ?? "0",
            assetImage: "ether_white"
        )
        priceChartContainerView.addSubview(etherPreviewView)
        etherPricePreview = etherPreviewView

        let etherChartTapGesture = UITapGestureRecognizer(target: self, action: #selector(etherChartTapped))
        etherPreviewView.addGestureRecognizer(etherChartTapGesture)

        let bitcoinCashPreviewViewFrame = CGRect(
            x: 0,
            y: etherPreviewView.frame.origin.y + etherPreviewView.frame.size.height + previewViewSpacing,
            width: (view.frame.size.width - (horizontalPadding * 2)),
            height: previewViewHeight
        )
        let bitcoinCashPreviewView = BCPricePreviewView(
            frame: bitcoinCashPreviewViewFrame,
            assetName: AssetType.bitcoinCash.description,
            price: getBchPrice() ?? "0",
            assetImage: "bitcoin_cash_white"
        )
        priceChartContainerView.addSubview(bitcoinCashPreviewView)
        bitcoinCashPricePreview = bitcoinCashPreviewView

        let bitcoinCashChartTapGesture = UITapGestureRecognizer(target: self, action: #selector(bitcoinCashChartTapped))
        bitcoinCashPreviewView.addGestureRecognizer(bitcoinCashChartTapGesture)

        self.priceChartContainerView = priceChartContainerView
    }

    @objc private func resetScrollView() {
        scrollView.setContentOffset(CGPoint.zero, animated: false)
    }

    // MARK: - View Helpers

    private func showError(message: String) {
        guard BlockchainSettings.App.shared.isPinSet,
            AuthenticationCoordinator.shared.pinEntryViewController == nil,
            wallet.isInitialized(),
            tabControllerManager.tabViewController.selectedIndex() == Int32(DashboardTab.dashboard.rawValue),
            ModalPresenter.shared.modalView == nil else {
                return
        }
        // NOTE: May have to be presented in `self.view.window.rootViewController` instead of `self`
        AlertViewPresenter.shared.standardError(message: message, title: LocalizationConstants.Errors.error, in: self)
    }

    // MARK: - Text Helpers

    private func dateStringFromGraphValue(value: Double) -> String? {
        guard let dateFormat = getDateFormat() else {
            Logger.shared.error("Failed to get date format!")
            return nil
        }
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }

    private func getDateFormat() -> String? {
        let key = UserDefaults.Keys.graphTimeFrameKey.rawValue
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
            let timeFrame = NSKeyedUnarchiver.unarchiveObject(with: data) as? GraphTimeFrame else {
                Logger.shared.error("Failed to unarchive the data object with key \(key)")
                return nil
        }
        guard let dateFormat = timeFrame.dateFormat else {
            Logger.shared.error("Failed to get date format from GraphTimeFrame!")
            return nil
        }
        return dateFormat
    }

    private func getBtcPrice() -> String? {
        guard wallet.isInitialized() else {
            Logger.shared.error("Returning nil because wallet was not initialized!")
            return nil
        }
        guard let stringValue = NumberFormatter.formatMoney(Constants.Conversions.satoshi, localCurrency: true) else {
            Logger.shared.error("Failed to format BTC price as string!")
            return nil
        }
        return stringValue
    }

    private func getBchPrice() -> String? {
        guard wallet.isInitialized() else {
            Logger.shared.error("Returning nil because wallet was not initialized!")
            return nil
        }
        guard let stringValue = NumberFormatter.formatBch(withSymbol: Constants.Conversions.satoshi, localCurrency: true) else {
            Logger.shared.error("Failed to format BCH price as string!")
            return nil
        }
        return stringValue
    }

    private func getEthPrice() -> String? {
        guard wallet.isInitialized() else {
            Logger.shared.error("Returning nil because wallet was not initialized!")
            return nil
        }
        guard lastEthExchangeRate != nil else {
            Logger.shared.error("Returning nil because lastEthExchangeRate was not set!")
            return nil
        }
        guard let stringValue = NumberFormatter.formatEthToFiat(withSymbol: "1", exchangeRate: lastEthExchangeRate) else {
            Logger.shared.error("Failed to format ETH price as string!")
            return nil
        }
        return stringValue
    }

    // NOTE: - The `getBalance` methods below return nil instead of zero if formatting fails (to avoid confusion with empty balance)

    // TICKET: IOS-???? - Support optionality for balance
    private func getBtcBalance() -> Double? {
        let balance = wallet.getTotalActiveBalance()
        guard let amount = NumberFormatter.formatAmount(balance, localCurrency: true),
            let doubleValue = numberFormatter.number(from: amount)?.doubleValue else {
                Logger.shared.error("Failed to format total active balance!")
                return nil
        }
        return doubleValue
    }

    // TICKET: IOS-???? - Support optionality for balance
    private func getEthBalance() -> Double? {
        guard let balance = wallet.getEthBalance() else {
            Logger.shared.error("Failed to get ETH balance!")
            return nil
        }
        guard let amount = NumberFormatter.formatEth(
            toFiat: balance,
            exchangeRate: wallet.latestEthExchangeRate,
            localCurrencyFormatter: NumberFormatter.localCurrencyFormatter
            ), let doubleValue = numberFormatter.number(from: amount)?.doubleValue else {
                Logger.shared.error("Failed to format ETH balance!")
                return nil
        }
        return doubleValue
    }

    // TICKET: IOS-???? - Support optionality for balance
    private func getBchBalance() -> Double? {
        let balance = wallet.getBchBalance()
        guard let amount = NumberFormatter.formatBch(balance, localCurrency: true),
            let doubleValue = numberFormatter.number(from: amount)?.doubleValue else {
                Logger.shared.error("Failed to format BCH balance!")
                return nil
        }
        return doubleValue
    }

    // TICKET: IOS-???? - Support optionality for balance
    private func getBtcWatchOnlyBalance() -> Double? {
        let balance =  wallet.getWatchOnlyBalance()
        guard let amount = NumberFormatter.formatAmount(balance, localCurrency: true),
            let doubleValue = numberFormatter.number(from: amount)?.doubleValue else {
                Logger.shared.error("Failed to format total active watch-only balance!")
                return nil
        }
        return doubleValue
    }

    private func reloadPricePreviews() {
        guard let btcPrice = getBtcPrice() else {
            Logger.shared.error("Failed to reload price previews because BTC price was empty!")
            return
        }
        guard let ethPrice = getEthPrice() else {
            Logger.shared.error("Failed to reload price previews because ETH price was empty!")
            return
        }
        guard let bchPrice = getBchPrice() else {
            Logger.shared.error("Failed to reload price previews because BCH price was empty!")
            return
        }
        bitcoinPricePreview.updatePrice(btcPrice)
        etherPricePreview.updatePrice(ethPrice)
        bitcoinCashPricePreview.updatePrice(bchPrice)
    }
}

// MARK: - BCBalancesChartView Delegate

// TICKET: IOS-???? - Decouple showTransactions* methods from tabControllerManager
extension DashboardController: BCBalancesChartViewDelegate {
    func bitcoinLegendTapped() {
        tabControllerManager.showTransactionsBitcoin()
    }

    func etherLegendTapped() {
        tabControllerManager.showTransactionsEther()
    }

    func bitcoinCashLegendTapped() {
        tabControllerManager.showTransactionsBitcoinCash()
    }

    func watchOnlyViewTapped() {
        BlockchainSettings.sharedAppInstance().symbolLocal = !BlockchainSettings.sharedAppInstance().symbolLocal
    }
}

// MARK: - BCPriceChartView Delegate

extension DashboardController: BCPriceChartViewDelegate {
    func addPriceChartView(_ assetType: LegacyAssetType) {
        switch assetType {
        case .bitcoin:
            bitcoinChartTapped()
        case .ether:
            etherChartTapped()
        case .bitcoinCash:
            bitcoinCashChartTapped()
        case .stellar:
            // TODO: implement stellarChartTapped()
            return
        }
    }

    func reloadPriceChartView(_ assetType: LegacyAssetType) {
        fetchChartDataForAsset(asset: assetType)
    }
}

// MARK: - IAxisValueFormatter

extension DashboardController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch axis {
        case chartContainerViewController.leftAxis():
            guard let latestMultiAddressResponse = WalletManager.shared.latestMultiAddressResponse,
                let symbolLocal = latestMultiAddressResponse.symbol_local,
                let symbol = symbolLocal.symbol else {
                    Logger.shared.warning("Failed to get symbol from latestMultiAddressResponse!")
                    return String()
            }
            return String(format: "%@%.f", symbol)
        case chartContainerViewController.xAxis():
            return dateStringFromGraphValue(value: value) ?? String()
        default:
            Logger.shared.warning("Warning: no axis found!")
            return String()
        }
    }
}

// TICKET: IOS-1249 - Refactor CardsViewController

// MARK: - AnnouncementCard Delegate

//extension DashboardController: AnnouncementCardDelegate {
//    func makeAnnouncement(📢 card: AnnouncementCard) {
//
//    }
//}
