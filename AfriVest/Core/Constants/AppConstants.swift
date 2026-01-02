//
//  AppConstants.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import Foundation


// MARK: - App Constants
struct AppConstants {
    static let appName = "AfriVest"
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.afrivest.app"
    
    
    // Currencies
    static let supportedCurrencies = ["UGX", "USD", "EUR", "GBP"]
    static let defaultCurrency = "UGX"
    
    // Transaction Limits
    struct Limits {
        static let minTransactionAmount = 1000.0
        static let maxTransactionAmount = 5_000_000.0
        static let minWithdrawalAmount = 5000.0
        static let minDepositAmount = 1000.0
    }
    
    // Validation
    struct Validation {
        static let minPasswordLength = 8
        static let phoneNumberPrefix = "256"
        static let phoneNumberLength = 12 // Including prefix
    }
    
    // Storage Keys
    struct StorageKeys {
        static let authToken = "auth_token"
        static let userId = "user_id"
        static let userEmail = "user_email"
        static let deviceToken = "device_token"
        static let biometricEnabled = "biometric_enabled"
        static let lastSyncDate = "last_sync_date"
        static let isFirstLaunch = "is_first_launch"
    }
    
    // Notification Names
    struct Notifications {
        static let userDidLogin = Notification.Name("userDidLogin")
        static let userDidLogout = Notification.Name("userDidLogout")
        static let tokenExpired = Notification.Name("tokenExpired")
        static let walletUpdated = Notification.Name("walletUpdated")
        static let transactionCompleted = Notification.Name("transactionCompleted")
    }
    
}
