//
//  MarketplaceService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import Foundation
import Alamofire

class MarketplaceService {
    static let shared = MarketplaceService()
    
    private init() {}
    
    // MARK: - Get Gold Products
    nonisolated func getGoldProducts() async throws -> [InvestmentProduct] {
        let queryParams = ["category_slug": "gold"]
        
        return try await APIClient.shared.requestWithURLParameters(
            APIConstants.Endpoints.investmentProducts,
            parameters: queryParams,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Current Gold Price
    nonisolated func getCurrentGoldPrice() async throws -> GoldPrice {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.goldCurrentPrice,
            method: .get,
            requiresAuth: true
        )
    }
}
