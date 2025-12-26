//
//  AssetsViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//


import Foundation
import Combine

@MainActor
class AssetsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var investments: [UserInvestment] = []
    @Published var policies: [InsurancePolicy] = []
    @Published var selectedTab = 0
    
    private let investmentService = InvestmentService.shared
    private let insuranceService = InsuranceService.shared
    
    func loadData() {
        loadInvestments()
        loadPolicies()
    }
    
    func loadInvestments() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedInvestments = try await investmentService.getUserInvestments(status: nil)
                self.investments = fetchedInvestments
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func loadPolicies() {
        Task {
            do {
                let fetchedPolicies = try await insuranceService.getInsurancePolicies(status: nil, policyType: nil)
                self.policies = fetchedPolicies
            } catch {
                print("Failed to load policies: \(error)")
            }
        }
    }
    
    var totalInvestmentValue: Double {
        investments.reduce(0) { $0 + (Double($1.currentValue) ?? 0) }
    }
    
    var totalReturns: Double {
        investments.reduce(0) { $0 + (Double($1.returnsEarned) ?? 0) }
    }
}
