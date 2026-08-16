//
//  DepositResponse.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 10/10/2025.
//

import Foundation

struct DepositResponse: Codable, Sendable {
    let transactionId: Int
    let reference: String
    let amount: Double
    let flutterwaveFee: Double?
    let serviceFee: Double?
    let totalFee: Double?
    let userPays: Double?
    let userReceives: Double?
    let currency: String
    let status: String?
    let network: String?
    let paymentData: PaymentData
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case reference, amount, currency, status, network
        case flutterwaveFee = "flutterwave_fee"
        case serviceFee = "service_fee"
        case totalFee = "total_fee"
        case userPays = "user_pays"
        case userReceives = "user_receives"
        case paymentData = "payment_data"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionId = try container.decode(Int.self, forKey: .transactionId)
        reference = try container.decode(String.self, forKey: .reference)
        if let intAmount = try? container.decode(Int.self, forKey: .amount) {
            amount = Double(intAmount)
        } else {
            amount = try container.decode(Double.self, forKey: .amount)
        }
        flutterwaveFee = try container.decodeIfPresent(Double.self, forKey: .flutterwaveFee)
        serviceFee = try container.decodeIfPresent(Double.self, forKey: .serviceFee)
        totalFee = try container.decodeIfPresent(Double.self, forKey: .totalFee)
        userPays = try container.decodeIfPresent(Double.self, forKey: .userPays)
        userReceives = try container.decodeIfPresent(Double.self, forKey: .userReceives)
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        network = try container.decodeIfPresent(String.self, forKey: .network)
        paymentData = try container.decode(PaymentData.self, forKey: .paymentData)
    }
    
    init(
        transactionId: Int,
        amount: Double,
        flutterwaveFee: Double?,
        serviceFee: Double?,
        totalFee: Double?,
        userPays: Double?,
        userReceives: Double?,
        currency: String,
        status: String?,
        network: String?,
        reference: String,
        paymentData: PaymentData
    ) {
        self.transactionId = transactionId
        self.amount = amount
        self.flutterwaveFee = flutterwaveFee
        self.serviceFee = serviceFee
        self.totalFee = totalFee
        self.userPays = userPays
        self.userReceives = userReceives
        self.currency = currency
        self.status = status
        self.network = network
        self.reference = reference
        self.paymentData = paymentData
    }
}

struct PaymentData: Codable, Sendable {
    let mode: String
    let url: String?
    let authorizationUrl: String?
    let redirectUrl: String?
    let flutterwaveTransactionId: String?
    
    enum CodingKeys: String, CodingKey {
        case mode
        case url
        case authorizationUrl = "authorization_url"
        case redirectUrl = "redirect_url"
        case flutterwaveTransactionId = "flutterwave_transaction_id"
    }
    
    var paymentUrl: String? {
        return url ?? authorizationUrl ?? redirectUrl
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mode = try container.decode(String.self, forKey: .mode)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        authorizationUrl = try container.decodeIfPresent(String.self, forKey: .authorizationUrl)
        redirectUrl = try container.decodeIfPresent(String.self, forKey: .redirectUrl)
        flutterwaveTransactionId = try container.decodeIfPresent(String.self, forKey: .flutterwaveTransactionId)
    }
    
    init(
        mode: String,
        url: String?,
        authorizationUrl: String?,
        redirectUrl: String?,
        flutterwaveTransactionId: String?
    ) {
        self.mode = mode
        self.url = url
        self.authorizationUrl = authorizationUrl
        self.redirectUrl = redirectUrl
        self.flutterwaveTransactionId = flutterwaveTransactionId
    }
}

struct TransactionStatus: Codable, Sendable {
    let transactionId: Int
    let reference: String
    let amount: String
    let currency: String
    let status: String
    let paymentMethod: String
    let network: String?
    let createdAt: String
    let updatedAt: String
    let message: String?
    let error: ErrorDetails?
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case reference, amount, currency, status
        case paymentMethod = "payment_method"
        case network
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case message, error
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionId = try container.decode(Int.self, forKey: .transactionId)
        reference = try container.decode(String.self, forKey: .reference)
        amount = try container.decode(String.self, forKey: .amount)
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decode(String.self, forKey: .status)
        paymentMethod = try container.decode(String.self, forKey: .paymentMethod)
        network = try container.decodeIfPresent(String.self, forKey: .network)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        error = try container.decodeIfPresent(ErrorDetails.self, forKey: .error)
    }
}

struct ErrorDetails: Codable, Sendable {
    let errorCode: String
    let message: String
    let action: String?
    let canRetry: Bool
    let severity: String
    
    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case message, action
        case canRetry = "can_retry"
        case severity
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try container.decode(String.self, forKey: .errorCode)
        message = try container.decode(String.self, forKey: .message)
        action = try container.decodeIfPresent(String.self, forKey: .action)
        canRetry = try container.decode(Bool.self, forKey: .canRetry)
        severity = try container.decode(String.self, forKey: .severity)
    }
}

struct BankDepositResponse: Codable, Sendable {
    let transactionId: Int
    let reference: String
    let amount: Double
    let currency: String
    let status: String?
    let paymentData: BankPaymentData
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case reference, amount, currency, status
        case paymentData = "payment_data"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionId = try container.decode(Int.self, forKey: .transactionId)
        reference = try container.decode(String.self, forKey: .reference)
        if let intAmount = try? container.decode(Int.self, forKey: .amount) {
            amount = Double(intAmount)
        } else {
            amount = try container.decode(Double.self, forKey: .amount)
        }
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        paymentData = try container.decode(BankPaymentData.self, forKey: .paymentData)
    }
}

struct BankPaymentData: Codable, Sendable {
    let mode: String?
    let redirectUrl: String?
    let authorizationUrl: String?
    let transferAccount: String?
    let transferBank: String?
    let transferReference: String?
    let transferNote: String?
    let transferAmount: String?
    let accountExpiration: String?
    let sortCode: String?
    let accountNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case mode
        case redirectUrl = "redirect_url"
        case authorizationUrl = "authorization_url"
        case transferAccount = "transfer_account"
        case transferBank = "transfer_bank"
        case transferReference = "transfer_reference"
        case transferNote = "transfer_note"
        case transferAmount = "transfer_amount"
        case accountExpiration = "account_expiration"
        case sortCode = "sort_code"
        case accountNumber = "account_number"
    }
}
