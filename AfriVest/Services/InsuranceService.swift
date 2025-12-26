//
//  InsuranceService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 23/12/2025.
//

import Foundation
import Alamofire

class InsuranceService {
    static let shared = InsuranceService()
    
    private init() {}
    
    // MARK: - Get Insurance Providers
    nonisolated func getInsuranceProviders() async throws -> [InsuranceProvider] {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.insuranceProviders,
            method: .get,
            requiresAuth: true
        )
    }
    
    // MARK: - Purchase Insurance Policy
    nonisolated func purchaseInsurancePolicy(request: PurchaseInsurancePolicyRequest) async throws -> InsurancePolicy {
        let beneficiariesArray = request.beneficiaries.map { beneficiary in
            return [
                "name": beneficiary.name,
                "relationship": beneficiary.relationship,
                "percentage": beneficiary.percentage
            ] as [String : Any]
        }
        
        var parameters: [String: Any] = [
            "partner_id": request.partnerId,
            "policy_type": request.policyType,
            "coverage_amount": request.coverageAmount,
            "premium_amount": request.premiumAmount,
            "premium_frequency": request.premiumFrequency,
            "beneficiaries": beneficiariesArray,
            "start_date": request.startDate,
            "end_date": request.endDate
        ]
        
        if let autoDeduct = request.autoDeductWallet {
            parameters["auto_deduct_wallet"] = autoDeduct
        }
        if let walletId = request.walletId {
            parameters["wallet_id"] = walletId
        }
        
        return try await APIClient.shared.request(
            APIConstants.Endpoints.insurancePolicies,
            method: .post,
            parameters: parameters,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Insurance Policies
    nonisolated func getInsurancePolicies(
        status: String? = nil,
        policyType: String? = nil
    ) async throws -> [InsurancePolicy] {
        var queryParams: [String: String] = [:]
        
        if let status = status {
            queryParams["status"] = status
        }
        if let policyType = policyType {
            queryParams["policy_type"] = policyType
        }
        
        return try await APIClient.shared.requestWithURLParameters(
            APIConstants.Endpoints.insurancePolicies,
            parameters: queryParams.isEmpty ? nil : queryParams,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Insurance Policy
    nonisolated func getInsurancePolicy(id: Int) async throws -> InsurancePolicy {
        return try await APIClient.shared.request(
            APIConstants.Endpoints.insurancePolicy(id: id),
            method: .get,
            requiresAuth: true
        )
    }
    
    func getClaims(policyId: Int) async throws -> [InsuranceClaim] {
        let endpoint = "/api/insurance-policies/\(policyId)/claims"
        let response: [InsuranceClaim] = try await APIClient.shared.request(
            endpoint,
            method: .get,
            requiresAuth: true
        )
        return response
    }

    func fileClaim(
        policyId: Int,
        claimType: String,
        amount: String,
        description: String,
        incidentDate: String
    ) async throws {
        let endpoint = "/api/insurance/policies/\(policyId)/claims"
        let parameters: [String: Any] = [
            "claim_type": claimType,
            "amount": amount,
            "description": description,
            "incident_date": incidentDate
        ]
        
        let _: MessageResponse = try await APIClient.shared.request(
            endpoint,
            method: .post,
            parameters: parameters,
            requiresAuth: true
        )
    }
}
