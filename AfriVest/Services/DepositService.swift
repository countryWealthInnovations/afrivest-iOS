//
//  DepositService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 10/10/2025.
//

import Foundation
import Alamofire

class DepositService: @unchecked Sendable {
    static let shared = DepositService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    func depositMobileMoney(
        amount: Double,
        currency: String,
        network: String,
        phoneNumber: String
    ) async throws -> DepositResponse {
        // Ensure phone starts with +
        let formattedPhone = phoneNumber.hasPrefix("+") ? phoneNumber : "+\(phoneNumber)"
        
        let parameters: [String: Any] = [
            "amount": amount,
            "currency": currency,
            "payment_method": "mobile_money",
            "payment_provider": network.lowercased(), // "mtn" or "airtel"
            "phone_number": formattedPhone
        ]
        
        return try await apiClient.request(
            APIConstants.Endpoints.depositMobileMoney,
            method: .post,
            parameters: parameters,
            requiresAuth: true
        )
    }
    
    func checkDepositStatus(transactionId: Int) async throws -> TransactionStatus {
        let endpoint = "\(APIConstants.Endpoints.checkDepositStatus)/\(transactionId)/check"
        
        return try await apiClient.request(
            endpoint,
            method: .get,
            requiresAuth: true
        )
    }
    
    func depositCard(
        amount: Double,
        currency: String,
        cardNumber: String,
        cvv: String,
        expiryMonth: String,
        expiryYear: String
    ) async throws -> DepositResponse {
        let parameters: [String: Any] = [
            "amount": amount,
            "currency": currency,
            "card_number": cardNumber,
            "cvv": cvv,
            "expiry_month": expiryMonth,
            "expiry_year": expiryYear
        ]
        
        return try await apiClient.request(
            APIConstants.Endpoints.depositCard,
            method: .post,
            parameters: parameters,
            requiresAuth: true
        )
    }
}
