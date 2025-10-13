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
        recipientId: Int,
        amount: Double,
        currency: String,
        description: String?
    ) async throws -> P2PTransferResponse {
        let parameters: [String: Any] = [
            "recipient_id": recipientId,
            "amount": amount,
            "currency": currency,
            "description": description ?? ""
        ]
        
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
}
