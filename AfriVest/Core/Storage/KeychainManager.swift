//
//  KeychainManager.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    // MARK: - Save Token
    func saveToken(_ token: String) -> Bool {
        return save(key: AppConstants.StorageKeys.authToken, value: token)
    }
    
    // MARK: - Get Token
    func getToken() -> String? {
        return get(key: AppConstants.StorageKeys.authToken)
    }
    
    // MARK: - Delete Token
    func deleteToken() -> Bool {
        return delete(key: AppConstants.StorageKeys.authToken)
    }
    
    // MARK: - Clear All
    func clearAll() {
        deleteToken()
        UserDefaults.standard.removeObject(forKey: AppConstants.StorageKeys.userId)
        UserDefaults.standard.removeObject(forKey: AppConstants.StorageKeys.userEmail)
        UserDefaults.standard.removeObject(forKey: AppConstants.StorageKeys.biometricEnabled)
    }
    
    // MARK: - Generic Save
    private func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete any existing item
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Generic Get
    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    // MARK: - Generic Delete
    @discardableResult
    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}


