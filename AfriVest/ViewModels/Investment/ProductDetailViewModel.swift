//
//  ProductDetailViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 26/12/2025.
//

import Foundation
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: InvestmentProduct
    @Published var amount: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var purchaseSuccess = false
    @Published var walletBalance: Double = 0.0
    
    private let investmentService = InvestmentService.shared
    
    init(product: InvestmentProduct) {
        self.product = product
        self.amount = product.minInvestment
    }
    
    func purchaseProduct() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")),
              amountValue >= Double(product.minInvestment) ?? 0 else {
            errorMessage = "Please enter a valid amount (minimum: \(product.minInvestmentFormatted))"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let request = PurchaseInvestmentRequest(
                    productId: product.id,
                    amount: amountValue,
                    currency: product.currency,
                    payoutFrequency: nil,
                    autoReinvest: false
                )
                
                let _ = try await investmentService.purchaseInvestment(request: request)
                self.purchaseSuccess = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    var isAmountValid: Bool {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")),
              let minAmount = Double(product.minInvestment) else {
            return false
        }
        return amountValue >= minAmount
    }
}
