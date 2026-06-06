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
    
    var defaultCurrency: String? {
        get { string(forKey: "default_currency") }
        set { set(newValue, forKey: "default_currency") }
    }
    
    var secondaryCurrency: String? {
        get { string(forKey: "secondary_currency") }
        set { set(newValue, forKey: "secondary_currency") }
    }
    
    // MARK: - Profile Caching
    private let profileCacheKey = "cached_profile_data"
    
    func saveProfile(_ profile: ProfileData) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(profile)
            defaults.set(data, forKey: profileCacheKey)
            
            // Also update individual fields for backwards compatibility
            userEmail = profile.email
            userId = String(profile.id)
            kycVerified = profile.kycVerified
            emailVerified = profile.emailVerified
            
            print("✅ Profile cached successfully")
        } catch {
            print("❌ Failed to cache profile: \(error.localizedDescription)")
        }
    }
    
    func getCachedProfile() -> ProfileData? {
        guard let data = defaults.data(forKey: profileCacheKey) else {
            print("⚠️ No cached profile found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let profile = try decoder.decode(ProfileData.self, from: data)
            print("✅ Cached profile loaded")
            return profile
        } catch {
            print("❌ Failed to decode cached profile: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearProfile() {
        defaults.removeObject(forKey: profileCacheKey)
        print("🗑️ Profile cache cleared")
    }
    
    func clearAll() {
        defaults.removeObject(forKey: profileCacheKey)
        defaults.removeObject(forKey: AppConstants.StorageKeys.userEmail)
        defaults.removeObject(forKey: AppConstants.StorageKeys.userId)
        defaults.removeObject(forKey: "email_verified")
        defaults.removeObject(forKey: "kyc_verified")
        defaults.removeObject(forKey: "default_currency")
        defaults.removeObject(forKey: "secondary_currency")
        defaults.removeObject(forKey: "forex_rates")
        defaults.removeObject(forKey: "kyc_banner_hidden")
        defaults.removeObject(forKey: "requires_currency_setup")
        print("🗑️ All user defaults cleared")
    }
}

