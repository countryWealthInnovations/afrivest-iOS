//
//  ProfileService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 08/10/2025.
//

import Foundation
import Alamofire

class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    
    // MARK: - Get Profile with Caching
    func getProfile(completion: @escaping (Result<ProfileData, Error>) -> Void) {
        // 1. Check cache first - return immediately if exists
        if let cachedProfile = UserDefaultsManager.shared.getCachedProfile() {
            completion(.success(cachedProfile))
        }
        
        // 2. Fetch fresh data from API (runs regardless of cache)
        fetchProfileFromAPI { result in
            switch result {
            case .success(let profileData):
                // Save to cache
                UserDefaultsManager.shared.saveProfile(profileData)
                
                // Update KYC status
                UserDefaultsManager.shared.kycVerified = profileData.kycVerified
                completion(.success(profileData))
                
            case .failure(let error):
                // Only propagate error if we don't have cached data
                if UserDefaultsManager.shared.getCachedProfile() == nil {
                    print("❌ Profile fetch error (no cache): \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("⚠️ Profile fetch error (using cache): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Fetch from API
    private func fetchProfileFromAPI(completion: @escaping (Result<ProfileData, Error>) -> Void) {
        guard let token = KeychainManager.shared.getToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        AF.request(
            "\(APIConstants.baseURL)/profile",
            method: .get,
            headers: headers
        )
        .validate()
        .responseData { response in
            // Log raw response for debugging
            if let data = response.data {
                if let json = String(data: data, encoding: .utf8) {
                    print("📦 API Response [/profile]: \(json)")
                }
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(ProfileAPIResponse.self, from: data)
                    
                    if apiResponse.success {
                        completion(.success(apiResponse.data))
                    } else {
                        completion(.failure(NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Unknown error"])))
                    }
                } catch {
                    print("❌ Profile decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Profile API Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Force Refresh (clears cache and fetches)
    func forceRefresh(completion: @escaping (Result<ProfileData, Error>) -> Void) {
        UserDefaultsManager.shared.clearProfile()
        fetchProfileFromAPI(completion: completion)
    }
}

// MARK: - Profile API Response
private struct ProfileAPIResponse: Codable, Sendable {
    let success: Bool
    let message: String?
    let data: ProfileData
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.data = try container.decode(ProfileData.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case success, message, data
    }
}
