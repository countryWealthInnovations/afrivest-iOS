//
//  WithdrawService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import Foundation
import Alamofire

class WithdrawService {
    static let shared = WithdrawService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    func withdrawMobileMoney(
        amount: Double,
        currency: String,
        network: String,
        phoneNumber: String
    ) async throws -> WithdrawResponse {
        let parameters: [String: Any] = [
            "amount": amount,
            "currency": currency,
            "network": network,
            "phone_number": phoneNumber
        ]
        
        return try await apiClient.request(
            APIConstants.Endpoints.withdrawMobileMoney,
            method: .post,
            parameters: parameters,
            requiresAuth: true
        )
    }
}
