//
//  PolicyDetailViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//

import Foundation
import Combine

@MainActor
class PolicyDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var claims: [InsuranceClaim] = []
    @Published var showFileClaimSheet = false
    
    let policy: InsurancePolicy
    private let insuranceService = InsuranceService.shared
    
    init(policy: InsurancePolicy) {
        self.policy = policy
    }
    
    func loadClaims() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedClaims = try await insuranceService.getClaims(policyId: policy.id)
                self.claims = fetchedClaims
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
