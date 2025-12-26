//
//  InvestmentViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import Foundation
import Combine

@MainActor
class InvestmentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var products: [InvestmentProduct] = []
    @Published var selectedCategorySlug: String?
    @Published var selectedSortOption: String?
    
    private let investmentService = InvestmentService.shared
    
    func loadProducts(categorySlug: String? = nil, sortBy: String? = nil) {
        isLoading = true
        errorMessage = nil
        selectedCategorySlug = categorySlug
        selectedSortOption = sortBy
        
        Task {
            do {
                let fetchedProducts = try await investmentService.getInvestmentProducts(
                    categorySlug: categorySlug,
                    riskLevel: nil,
                    sortBy: sortBy
                )
                self.products = fetchedProducts
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func filterByCategory(_ categorySlug: String?) {
        loadProducts(categorySlug: categorySlug, sortBy: selectedSortOption)
    }
    
    func sortProducts(_ sortBy: String) {
        loadProducts(categorySlug: selectedCategorySlug, sortBy: sortBy)
    }
}
