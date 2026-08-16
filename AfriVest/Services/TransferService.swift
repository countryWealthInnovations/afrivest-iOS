//
//  TransferService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import Foundation
import Alamofire

class TransferService {
    static let shared = TransferService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - P2P Transfer
    func transferP2P(
        recipientId: Int? = nil,
        recipientUuid: String? = nil,
        amount: Double,
        currency: String,
        description: String?
    ) async throws -> P2PTransferResponse {
        var parameters: [String: Any] = [
            "amount": amount,
            "currency": currency,
            "description": description ?? ""
        ]
        if let recipientUuid = recipientUuid {
            parameters["recipient_uuid"] = recipientUuid
        } else if let recipientId = recipientId {
            parameters["recipient_id"] = recipientId
        }
        
        return try await apiClient.request(
            APIConstants.Endpoints.p2pTransfer,
            method: .post,
            parameters: parameters,
            requiresAuth: true
        )
    }
    
    // MARK: - Search User by Phone or Email
    func searchUser(phoneOrEmail: String) async throws -> UserSearchResponse {
        let parameters: [String: String] = [
            "query": phoneOrEmail
        ]
        
        return try await apiClient.requestWithURLParameters(
            "/users/search",
            parameters: parameters,
            requiresAuth: true
        )
    }
    
    // MARK: - Lookup User by Uuid (from scanned QR)
    func lookupByUuid(_ uuid: String) async throws -> UserSearchResponse {
        return try await apiClient.requestWithURLParameters(
            "/users/lookup-by-uuid/\(uuid)",
            parameters: [String: String](),
            requiresAuth: true
        )
    }
}
