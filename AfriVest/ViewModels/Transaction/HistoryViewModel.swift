//
//  HistoryViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 11/10/2025.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var selectedFilter: String?
    @Published var isLastPage = false
    
    private var currentPage = 1
    private var totalPages = 1
    private let perPage = 20
    
    // MARK: - Load Transactions
    func loadTransactions() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        transactions.removeAll()
        filteredTransactions.removeAll()
        
        Task {
            do {
                let endpoint = APIConstants.Endpoints.transactions
                var parameters: [String: Any] = [
                    "page": currentPage,
                    "per_page": perPage
                ]
                
                if let filter = selectedFilter {
                    parameters["status"] = filter
                }

                let response: [Transaction] = try await APIClient.shared.request(
                    endpoint,
                    method: .get,
                    parameters: parameters,
                    encoding: URLEncoding.default,
                    requiresAuth: true
                )

                transactions = response
                filteredTransactions = response
                isLastPage = response.isEmpty || response.count < perPage
                isLoading = false
                
                print("✅ Loaded \(response.count) transactions")
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
                print("❌ Failed to load transactions: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Load More Transactions (Pagination)
    func loadMoreTransactions() {
        guard !isLoading && !isLastPage else { return }
        
        isLoading = true
        currentPage += 1
        
        Task {
            do {
                let endpoint = APIConstants.Endpoints.transactions
                var parameters: [String: Any] = [
                    "page": currentPage,
                    "per_page": perPage
                ]
                
                if let filter = selectedFilter {
                    parameters["status"] = filter
                }

                let response: [Transaction] = try await APIClient.shared.request(
                    endpoint,
                    method: .get,
                    parameters: parameters,
                    encoding: URLEncoding.default,
                    requiresAuth: true
                )

                if !response.isEmpty {
                    transactions.append(contentsOf: response)
                    filteredTransactions = transactions
                }
                isLastPage = response.isEmpty || response.count < perPage
                isLoading = false
                
                print("✅ Loaded more transactions: page \(currentPage) - \(response.count) new items")
            } catch {
                currentPage -= 1
                errorMessage = error.localizedDescription
                isLoading = false
                print("❌ Failed to load more transactions: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Filter Transactions
    func filterTransactions(_ status: String?) {
        selectedFilter = status
        loadTransactions()
    }
    
    // MARK: - Refresh Transactions
    func refreshTransactions() async {
        loadTransactions()
    }
    
    // MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
}
