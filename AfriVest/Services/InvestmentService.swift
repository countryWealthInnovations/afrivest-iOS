//
//  InvestmentService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import Foundation
import Alamofire

class InvestmentService {
    static let shared = InvestmentService()
    
    private init() {}
    
    // MARK: - Get Investment Categories
    nonisolated func getInvestmentCategories() async throws -> [InvestmentCategory] {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.investmentCategories,
            method: .get,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Investment Category
    nonisolated func getInvestmentCategory(slug: String) async throws -> InvestmentCategory {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.investmentCategory(slug: slug),
            method: .get,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Investment Products
    nonisolated func getInvestmentProducts(
        categorySlug: String? = nil,
        riskLevel: String? = nil,
        sortBy: String? = nil
    ) async throws -> [InvestmentProduct] {
        var queryParams: [String: String] = [:]
        
        if let categorySlug = categorySlug {
            queryParams["category_slug"] = categorySlug
        }
        if let riskLevel = riskLevel {
            queryParams["risk_level"] = riskLevel
        }
        if let sortBy = sortBy {
            queryParams["sort_by"] = sortBy
        }
        
        return try await APIClient.shared.requestWithURLParameters(
            APIConstants.Endpoints.investmentProducts,
            parameters: queryParams,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Featured Products
    nonisolated func getFeaturedProducts() async throws -> [InvestmentProduct] {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.featuredInvestmentProducts,
            method: .get,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Investment Product
    nonisolated func getInvestmentProduct(slug: String) async throws -> InvestmentProduct {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.investmentProduct(slug: slug),
            method: .get,
            requiresAuth: true
        )
    }
    
    // MARK: - Purchase Investment
    nonisolated func purchaseInvestment(request: PurchaseInvestmentRequest) async throws -> UserInvestment {
        let parameters: [String: Any] = [
            "product_id": request.productId,
            "amount": request.amount,
            "currency": request.currency,
            "payout_frequency": request.payoutFrequency as Any,
            "auto_reinvest": request.autoReinvest as Any
        ]
        
        return try await APIClient.shared.request(
            APIConstants.Endpoints.userInvestments,
            method: .post,
            parameters: parameters,
            requiresAuth: true
        )
    }
    
    // MARK: - Get User Investments
    nonisolated func getUserInvestments(status: String? = nil) async throws -> [UserInvestment] {
        var queryParams: [String: String] = [:]
        
        if let status = status {
            queryParams["status"] = status
        }
        
        return try await APIClient.shared.requestWithURLParameters(
            APIConstants.Endpoints.userInvestments,
            parameters: queryParams.isEmpty ? nil : queryParams,
            requiresAuth: true
        )
    }
    
    // MARK: - Get User Investment
    nonisolated func getUserInvestment(id: Int) async throws -> UserInvestment {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.userInvestment(id: id),
            method: .get,
            requiresAuth: true
        )
    }
}
