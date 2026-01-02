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
        guard !isLoading else { return }
        loadInvestments()
        loadPolicies()
    }

    func refreshData() async {
        await MainActor.run {
            investments.removeAll()
            policies.removeAll()
        }
        loadData()
    }
    
    func loadInvestments() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let fetchedInvestments = try await investmentService.getUserInvestments(status: nil)
                await MainActor.run {
                    self.investments = fetchedInvestments
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    print("❌ Failed to load investments: \(error)")
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadPolicies() {
        Task {
            do {
                let fetchedPolicies = try await insuranceService.getInsurancePolicies(status: nil, policyType: nil)
                await MainActor.run {
                    self.policies = fetchedPolicies
                }
            } catch let decodingError as DecodingError {
                await MainActor.run {
                    print("❌ Decoding error: \(decodingError)")
                    if case .keyNotFound(let key, let context) = decodingError {
                        print("Missing key: \(key.stringValue), context: \(context.debugDescription)")
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ Failed to load policies: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var totalInvestmentValue: Double {
        investments.reduce(0) { $0 + (Double($1.currentValue) ?? 0) }
    }
    
    var totalReturns: Double {
        investments.reduce(0) { result, investment in
            if let returnsEarned = investment.returnsEarned,
               let returns = Double(returnsEarned) {
                return result + returns
            } else {
                // Calculate returns if not provided
                let invested = Double(investment.amountInvested) ?? 0.0
                let current = Double(investment.currentValue) ?? 0.0
                return result + (current - invested)
            }
        }
    }
}
