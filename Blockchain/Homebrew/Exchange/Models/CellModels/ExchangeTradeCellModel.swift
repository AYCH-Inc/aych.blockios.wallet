//
//  ExchangeTradeCellModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

enum TradeStatus {
    case noDeposits
    case complete
    case resolved
    case inProgress
    case pendingRefund
    case delayed
    case refunded
    case cancelled
    case failed
    case expired
    case none
    
    init(homebrew: String) {
        switch homebrew {
        case "NONE":
            self = .none
        case "PENDING_EXECUTION",
             "PENDING_DEPOSIT",
             "FINISHED_DEPOSIT",
             "PENDING_WITHDRAWAL":
            self = .inProgress
        case "PENDING_REFUND":
            self = .pendingRefund
        case "REFUNDED":
            self = .refunded
        case "FINISHED":
            self = .complete
        case "FAILED":
            self = .failed
        case "EXPIRED":
            self = .expired
        case "DELAYED":
            self = .delayed
        default:
            self = .none
        }
    }
}

extension TradeStatus {
    
    var tintColor: UIColor {
        switch self {
        case .complete,
             .refunded,
             .resolved,
             .cancelled:
            return .green
        case .inProgress,
             .noDeposits,
             .delayed:
            return #colorLiteral(red: 0.96, green: 0.65, blue: 0.14, alpha: 1)
        case .pendingRefund:
            return #colorLiteral(red: 0.96, green: 0.65, blue: 0.14, alpha: 1)
        case .failed:
            return #colorLiteral(red: 0.95, green: 0.42, blue: 0.44, alpha: 1)
        case .expired,
             .none:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var displayValue: String {
        switch self {
        case .complete,
             .resolved:
            return LocalizationConstants.Swap.complete
        case .delayed:
            return LocalizationConstants.Swap.delayed
        case .pendingRefund:
            return LocalizationConstants.Swap.refundInProgress
        case .refunded,
             .cancelled:
            return LocalizationConstants.Swap.refunded
        case .failed:
            return LocalizationConstants.Swap.failed
        case .expired:
            return LocalizationConstants.Swap.expired
        case .inProgress,
             .noDeposits,
             .none:
            return LocalizationConstants.Swap.inProgress
        }
    }
}

extension ExchangeTradeCellModel {
    var alertModel: AlertModel? {
        guard let supportURL = URL(string: Constants.Url.supportTicketBuySellExchange) else {
            return nil
        }
        
        let action =  AlertAction(
            style: .confirm(LocalizationConstants.KYC.contactSupport),
            metadata: .url(supportURL)
        )
        let generic = AlertModel(
            headline: LocalizationConstants.Swap.somethingNotRight,
            body: LocalizationConstants.Swap.somethingNotRightDetails,
            actions: [action],
            style: .sheet
        )
        switch status {
        case .expired, .failed:
            return generic
        case .inProgress:
            guard let yesterday = Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: Date()
                ) else { return nil }
            if transactionDate < yesterday {
                return generic
            }
            return nil
        case .delayed:
            guard let url = URL(string: "https://support.blockchain.com/hc/en-us/articles/360023819791-Why-is-my-order-delayed-") else {
                return nil
            }
            let learnMore = AlertAction(
                style: .confirm(LocalizationConstants.Swap.learnMore),
                metadata: .url(url)
            )
            let delayed = AlertModel(
                headline: LocalizationConstants.Swap.networkDelay,
                body: LocalizationConstants.Swap.dontWorry,
                actions: [learnMore],
                style: .sheet
            )
            return delayed
        default:
            return nil
        }
    }
    
    var feeDisplayValue: String {
        return withdrawalFee.value + " " + withdrawalFee.symbol
    }

    var amountFiatValue: String {
        return fiatValue.value
    }
    
    var amountFiatSymbol: String {
        return fiatValue.symbol
    }
    
    var amountDepositedCrypto: String {
        if let value = deposit?.value, let symbol = deposit?.symbol {
            return value + " " + symbol
        } else {
            let zero = "0"
            guard let symbol = pair?.from.symbol else {
                return zero
            }
            return zero + " " + symbol
        }
    }
    
    var amountReceivedCrypto: String {
        if let value = withdrawal?.value, let symbol = withdrawal?.symbol {
            return value + " " + symbol
        } else {
            let zero = "0"
            guard let symbol = pair?.to.symbol else {
                return zero
            }
            return zero + " " + symbol
        }
    }
    
    var transactionDate: Date {
        return createdAt
    }
    
    var formattedDate: String {
        return DateFormatter.timeAgoString(from: createdAt)
    }
}

struct ExchangeTradeCellModel: Decodable {

    let identifier: String
    let status: TradeStatus
    let createdAt: Date
    let updatedAt: Date
    let pair: TradingPair?
    let refundAddress: String
    let rate: String?
    let depositAddress: String
    let deposit: SymbolValue?
    let withdrawalAddress: String
    let withdrawal: SymbolValue?
    let withdrawalFee: SymbolValue
    let fiatValue: SymbolValue
    let depositTxHash: String?
    let withdrawalTxHash: String?

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case status = "state"
        case createdAt
        case updatedAt
        case pair
        case refundAddress
        case rate
        case depositAddress
        case deposit
        case withdrawalAddress
        case withdrawal
        case withdrawalFee
        case fiatValue
        case depositTxHash
        case withdrawalTxHash
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let updated = try values.decode(String.self, forKey: .updatedAt)
        let inserted = try values.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter.sessionDateFormat
        let legacyFormatter = DateFormatter.iso8601Format
        
        /// Some trades don't have a consistant date format. Some
        /// use the same format as what we use for establishing a
        /// secure session, some use ISO8601.
        if let transactionResult = formatter.date(from: inserted) {
            createdAt = transactionResult
        } else if let transactionResult = legacyFormatter.date(from: inserted) {
            createdAt = transactionResult
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: values,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
        
        if let updatedResult = formatter.date(from: updated) {
            updatedAt = updatedResult
        } else if let updatedResult = legacyFormatter.date(from: updated) {
            updatedAt = updatedResult
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .updatedAt,
                in: values,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
        
        identifier = try values.decode(String.self, forKey: .identifier)
        let pairValue = try values.decode(String.self, forKey: .pair)
        let statusValue = try values.decode(String.self, forKey: .status)
        status = TradeStatus(homebrew: statusValue)
        pair = TradingPair(string: pairValue)
        refundAddress = try values.decode(String.self, forKey: .refundAddress)
        rate = try values.decodeIfPresent(String.self, forKey: .rate)
        depositAddress = try values.decode(String.self, forKey: .depositAddress)
        deposit = try values.decodeIfPresent(SymbolValue.self, forKey: .deposit)
        withdrawalAddress = try values.decode(String.self, forKey: .withdrawalAddress)
        withdrawal = try values.decodeIfPresent(SymbolValue.self, forKey: .withdrawal)
        withdrawalFee = try values.decode(SymbolValue.self, forKey: .withdrawalFee)
        fiatValue = try values.decode(SymbolValue.self, forKey: .fiatValue)
        depositTxHash = try values.decodeIfPresent(String.self, forKey: .depositTxHash)
        withdrawalTxHash = try values.decodeIfPresent(String.self, forKey: .withdrawalTxHash)
    }
}

extension ExchangeTradeCellModel: Equatable {
    static func ==(lhs: ExchangeTradeCellModel, rhs: ExchangeTradeCellModel) -> Bool {
        return lhs.status == rhs.status &&
        lhs.createdAt == rhs.createdAt &&
        lhs.pair == rhs.pair
    }
}

extension ExchangeTradeCellModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(status)
        hasher.combine(pair)
        hasher.combine(createdAt)
    }
}

extension ExchangeTrade {
    
    fileprivate func minerFeeCryptoAmount() -> String? {
        guard let assetType = AssetType(stringValue: minerCurrency()) else { return nil }
        return assetType.toCrypto(amount: minerFee as Decimal)
    }
    
    fileprivate func inboundFiatAmount() -> String? {
        guard let toAsset = pair.components(separatedBy: "_").last else { return nil }
        guard let assetType = AssetType(stringValue: toAsset) else { return nil }
        return assetType.toFiat(amount: withdrawalAmount as Decimal)
    }
    
    fileprivate func inboundCryptoAmount() -> String? {
        guard let currencySymbol = withdrawalCurrency() else { return nil }
        guard let assetType = AssetType(stringValue: currencySymbol) else { return nil }
        return assetType.toCrypto(amount: withdrawalAmount as Decimal)
    }
    
    fileprivate func outboundFiatAmount() -> String? {
        guard let fromAsset = pair.components(separatedBy: "_").first else { return nil }
        guard let assetType = AssetType(stringValue: fromAsset) else { return nil }
        return assetType.toFiat(amount: depositAmount as Decimal)
    }
    
    fileprivate func outboundCryptoAmount() -> String? {
        guard let currencySymbol = depositCurrency() else { return nil }
        guard let assetType = AssetType(stringValue: currencySymbol) else { return nil }
        return assetType.toCrypto(amount: depositAmount as Decimal)
    }
}
