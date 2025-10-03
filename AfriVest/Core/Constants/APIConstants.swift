//
//  APIConstants.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import Foundation

struct APIConstants {
// MARK: - Base URL
#if DEBUG
static let baseURL = "https://afrivest.countrywealth.ug/api"
#else
static let baseURL = "https://afrivest.countrywealth.ug/api"
#endif


// MARK: - Endpoints
struct Endpoints {
    // Authentication
    static let register = "/auth/register"
    static let login = "/auth/login"
    static let logout = "/auth/logout"
    static let me = "/auth/me"
    static let verifyOTP = "/auth/verify-otp"
    static let resendOTP = "/auth/resend-otp"
    static let forgotPassword = "/auth/forgot-password"
    static let resetPassword = "/auth/reset-password"
    
    // Profile
    static let profile = "/profile"
    static let updatePassword = "/profile/password"
    static let uploadAvatar = "/profile/avatar"
    static let deleteAvatar = "/profile/avatar"
    
    // Wallets
    static let wallets = "/wallets"
    static func wallet(currency: String) -> String {
        return "/wallets/\(currency)"
    }
    static func walletTransactions(currency: String) -> String {
        return "/wallets/\(currency)/transactions"
    }
    
    // Deposits
    static let depositCard = "/deposits/card"
    static let depositMobileMoney = "/deposits/mobile-money"
    static let depositBank = "/deposits/bank-transfer"
    static func depositStatus(reference: String) -> String {
        return "/deposits/\(reference)/status"
    }
    
    // Withdrawals
    static let withdrawBank = "/withdrawals/bank"
    static let withdrawMobileMoney = "/withdrawals/mobile-money"
    static func withdrawalStatus(reference: String) -> String {
        return "/withdrawals/\(reference)/status"
    }
    
    // Transfers
    static let p2pTransfer = "/transfers/p2p"
    static let insurance = "/transfers/insurance"
    static let investment = "/transfers/investment"
    static let billPayment = "/transfers/bill-payment"
    static let gold = "/transfers/gold"
    static let crypto = "/transfers/crypto"
    static let transferHistory = "/transfers/history"
    
    // Transactions
    static let transactions = "/transactions"
    static func transaction(id: Int) -> String {
        return "/transactions/\(id)"
    }
    static func transactionReceipt(id: Int) -> String {
        return "/transactions/\(id)/receipt"
    }
    
    // Forex
    static let forexRates = "/forex/rates"
    static let forexConvert = "/forex/convert"
    
    // Dashboard
    static let dashboard = "/dashboard"
}

// MARK: - Headers
struct Headers {
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
    static let accept = "Accept"
    static let applicationJSON = "application/json"
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Status Codes
struct StatusCodes {
    static let success = 200
    static let created = 201
    static let noContent = 204
    static let badRequest = 400
    static let unauthorized = 401
    static let forbidden = 403
    static let notFound = 404
    static let validationError = 422
    static let tooManyRequests = 429
    static let serverError = 500
}

// MARK: - Timeouts
static let requestTimeout: TimeInterval = 30
static let resourceTimeout: TimeInterval = 60


}
