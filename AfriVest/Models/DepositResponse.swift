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
    let amount: String
    let currency: String
    let status: String?  // ← CHANGED: Made optional
    let network: String?
    let paymentData: PaymentData
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case reference, amount, currency, status, network
        case paymentData = "payment_data"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionId = try container.decode(Int.self, forKey: .transactionId)
        reference = try container.decode(String.self, forKey: .reference)
        amount = try container.decode(String.self, forKey: .amount)
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decodeIfPresent(String.self, forKey: .status)  // ← CHANGED
        network = try container.decodeIfPresent(String.self, forKey: .network)
        paymentData = try container.decode(PaymentData.self, forKey: .paymentData)
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
