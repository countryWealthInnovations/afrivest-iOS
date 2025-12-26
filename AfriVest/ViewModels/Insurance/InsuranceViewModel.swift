//
//  InsuranceViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//


import Foundation
import Combine

@MainActor
class InsuranceViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var providers: [InsuranceProvider] = []
    @Published var policies: [InsurancePolicy] = []
    
    private let insuranceService = InsuranceService.shared
    
    func loadProviders() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedProviders = try await insuranceService.getInsuranceProviders()
                self.providers = fetchedProviders
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func loadPolicies(status: String? = nil, policyType: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedPolicies = try await insuranceService.getInsurancePolicies(
                    status: status,
                    policyType: policyType
                )
                self.policies = fetchedPolicies
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
