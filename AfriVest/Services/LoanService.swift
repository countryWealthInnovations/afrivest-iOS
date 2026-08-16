//
//  LoanService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import Foundation
import Alamofire

class LoanService {
    static let shared = LoanService()
    private let apiClient = APIClient.shared
    private init() {}
    
    func getTerms() async throws -> [LoanTerm] {
        try await apiClient.request("/loans/terms", method: .get, parameters: nil, requiresAuth: true)
    }
    
    func getAvailable() async throws -> [Loan] {
        try await apiClient.request("/loans/available", method: .get, parameters: nil, requiresAuth: true)
    }
    
    func getMyLoans() async throws -> MyLoans {
        try await apiClient.request("/loans/my", method: .get, parameters: nil, requiresAuth: true)
    }
    
    func getLoan(uuid: String) async throws -> Loan {
        try await apiClient.request("/loans/\(uuid)", method: .get, parameters: nil, requiresAuth: true)
    }
    
    func requestLoan(amount: Double, term: String, currency: String, purpose: String?) async throws -> Loan {
        var params: [String: Any] = ["amount": amount, "term": term, "currency": currency]
        if let purpose = purpose { params["purpose"] = purpose }
        let wrapper: LoanWrapper = try await apiClient.request(
            "/loans/request", method: .post, parameters: params, requiresAuth: true)
        return wrapper.loan
    }
    
    func fund(uuid: String) async throws -> Loan {
        let wrapper: LoanWrapper = try await apiClient.request(
            "/loans/\(uuid)/fund", method: .post, parameters: [:], requiresAuth: true)
        return wrapper.loan
    }
    
    func repay(uuid: String, amount: Double) async throws -> Loan {
        let wrapper: LoanWrapper = try await apiClient.request(
            "/loans/\(uuid)/repay", method: .post, parameters: ["amount": amount], requiresAuth: true)
        return wrapper.loan
    }
}
