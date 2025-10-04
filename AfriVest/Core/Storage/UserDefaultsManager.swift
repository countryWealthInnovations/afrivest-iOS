//
//  UserDefaultsManager.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Generic Methods
    func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func object(forKey key: String) -> Any? {
        return defaults.object(forKey: key)
    }
    
    func string(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    func bool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    func integer(forKey key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    func double(forKey key: String) -> Double {
        return defaults.double(forKey: key)
    }
    
    func removeObject(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    func synchronize() -> Bool {
        return defaults.synchronize()
    }
    
    // MARK: - App-specific convenience methods
    var isFirstLaunch: Bool {
        get { bool(forKey: AppConstants.StorageKeys.isFirstLaunch) }
        set { set(newValue, forKey: AppConstants.StorageKeys.isFirstLaunch) }
    }
    
    var biometricEnabled: Bool {
        get { bool(forKey: AppConstants.StorageKeys.biometricEnabled) }
        set { set(newValue, forKey: AppConstants.StorageKeys.biometricEnabled) }
    }
    
    var userEmail: String? {
        get { string(forKey: AppConstants.StorageKeys.userEmail) }
        set { set(newValue, forKey: AppConstants.StorageKeys.userEmail) }
    }
    
    var userId: String? {
        get { string(forKey: AppConstants.StorageKeys.userId) }
        set { set(newValue, forKey: AppConstants.StorageKeys.userId) }
    }
    
    var deviceToken: String? {
        get { string(forKey: AppConstants.StorageKeys.deviceToken) }
        set { set(newValue, forKey: AppConstants.StorageKeys.deviceToken) }
    }
    
    var lastSyncDate: Date? {
        get { defaults.object(forKey: AppConstants.StorageKeys.lastSyncDate) as? Date }
        set { set(newValue, forKey: AppConstants.StorageKeys.lastSyncDate) }
    }
    
    // MARK: - Verification Status
    var emailVerified: Bool {
        get { bool(forKey: "email_verified") }
        set { set(newValue, forKey: "email_verified") }
    }
    
    var kycVerified: Bool {
        get { bool(forKey: "kyc_verified") }
        set { set(newValue, forKey: "kyc_verified") }
    }
}

