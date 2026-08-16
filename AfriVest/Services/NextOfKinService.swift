//
//  NextOfKinService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 15/08/2026.
//

import Foundation
import Alamofire

struct NextOfKinData: Decodable, Sendable {
    let id: Int
    let name: String
    let relationship: String
    let relationshipLabel: String?
    let phoneNumber: String
    let email: String
    let notified: Bool
    let notifiedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, relationship, notified
        case relationshipLabel = "relationship_label"
        case phoneNumber = "phone_number"
        case email
        case notifiedAt = "notified_at"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        relationship = try container.decode(String.self, forKey: .relationship)
        relationshipLabel = try container.decodeIfPresent(String.self, forKey: .relationshipLabel)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        email = try container.decode(String.self, forKey: .email)
        notified = try container.decode(Bool.self, forKey: .notified)
        notifiedAt = try container.decodeIfPresent(String.self, forKey: .notifiedAt)
    }
}

class NextOfKinService {
    static let shared = NextOfKinService()
    private init() {}
    
    static let relationships: [(key: String, label: String)] = [
        ("spouse", "Spouse"),
        ("parent", "Parent"),
        ("sibling", "Sibling"),
        ("child", "Child"),
        ("other", "Other"),
    ]
    
    /// Returns nil when the user has no next of kin on file (server sends data: null).
    func get() async throws -> NextOfKinData? {
        do {
            let data: NextOfKinData = try await APIClient.shared.request(
                "/next-of-kin", method: .get, parameters: nil, requiresAuth: true
            )
            return data
        } catch APIError.decodingError {
            return nil
        }
    }
    
    func save(name: String, relationship: String, phone: String, email: String) async throws -> NextOfKinData {
        let params: [String: Any] = [
            "name": name, "relationship": relationship,
            "phone_number": phone, "email": email,
        ]
        return try await APIClient.shared.request(
            "/next-of-kin", method: .post, parameters: params, requiresAuth: true
        )
    }
    
    func delete() async throws {
        let _: EmptyDataResponse = try await APIClient.shared.request(
            "/next-of-kin", method: .delete, parameters: nil, requiresAuth: true
        )
    }
}
