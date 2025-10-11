//
//  TransactionService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 11/10/2025.
//

import Foundation
import Alamofire

class TransactionService {
    static let shared = TransactionService()
    
    private init() {}
    
    // Get transaction history with filters
    func getTransactionHistory(
        page: Int = 1,
        perPage: Int = 20,
        status: String? = nil
    ) async throws -> [Transaction] {
        var parameters: [String: String] = [
            "page": "\(page)",
            "per_page": "\(perPage)"
        ]
        
        if let status = status {
            parameters["status"] = status
        }
        
        do {
            let response: [Transaction] = try await APIClient.shared.requestWithURLParameters(
                APIConstants.Endpoints.transactions,
                parameters: parameters,
                requiresAuth: true
            )
            return response
        } catch {
            throw error
        }
    }
    
    // Get single transaction
    func getTransaction(id: Int) async throws -> Transaction {
        let endpoint = APIConstants.Endpoints.transaction(id: id)
        let response: Transaction = try await APIClient.shared.request(
            endpoint,
            method: .get,
            requiresAuth: true
        )
        return response
    }
}
