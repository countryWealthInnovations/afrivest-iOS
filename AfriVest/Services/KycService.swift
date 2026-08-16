//
//  KycService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import Foundation
import Alamofire

struct KycSessionData: Codable, Sendable {
    let session_id: String?
    let session_token: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey { case session_id, session_token, url }
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        session_id = try c.decodeIfPresent(String.self, forKey: .session_id)
        session_token = try c.decodeIfPresent(String.self, forKey: .session_token)
        url = try c.decodeIfPresent(String.self, forKey: .url)
    }
}

struct KycStatusData: Codable, Sendable {
    let status: String?
    let verified: Bool?
    let reviewed_at: String?
    
    enum CodingKeys: String, CodingKey { case status, verified, reviewed_at }
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        verified = try c.decodeIfPresent(Bool.self, forKey: .verified)
        reviewed_at = try c.decodeIfPresent(String.self, forKey: .reviewed_at)
    }
}

class KycService {
    static let shared = KycService()
    private let apiClient = APIClient.shared
    private init() {}
    
    func createSession() async throws -> KycSessionData {
        try await apiClient.request("/kyc/session", method: .post, parameters: [:], requiresAuth: true)
    }
    
    func getStatus() async throws -> KycStatusData {
        try await apiClient.request("/kyc/status", method: .get, parameters: nil, requiresAuth: true)
    }
}
