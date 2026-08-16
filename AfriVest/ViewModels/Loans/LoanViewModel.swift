//
//  LoanViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class LoanViewModel: ObservableObject {
    @Published var terms: [LoanTerm] = []
    @Published var borrowed: [Loan] = []
    @Published var lent: [Loan] = []
    @Published var available: [Loan] = []
    @Published var detail: Loan?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Published signals instead of completion closures
    @Published var createdLoan: Loan?
    @Published var didFund = false
    
    private let service = LoanService.shared
    
    func loadTerms() {
        Task {
            do { terms = try await service.getTerms() }
            catch { errorMessage = error.localizedDescription }
        }
    }
    
    func loadMyLoans() {
        Task {
            isLoading = true
            do {
                let my = try await service.getMyLoans()
                borrowed = my.borrowed
                lent = my.lent
            } catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    
    func loadAvailable() {
        Task {
            isLoading = true
            do { available = try await service.getAvailable() }
            catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    
    func loadDetail(uuid: String) {
        Task {
            isLoading = true
            do { detail = try await service.getLoan(uuid: uuid) }
            catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    
    func requestLoan(amount: Double, term: String, currency: String, purpose: String?) {
        Task {
            isLoading = true
            do {
                let loan = try await service.requestLoan(amount: amount, term: term, currency: currency, purpose: purpose)
                successMessage = "Loan request submitted"
                createdLoan = loan
            } catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    
    func fund(uuid: String) {
        Task {
            isLoading = true
            do {
                detail = try await service.fund(uuid: uuid)
                successMessage = "Loan funded"
                didFund = true
            } catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    
    func repay(uuid: String, amount: Double) {
        Task {
            isLoading = true
            do {
                detail = try await service.repay(uuid: uuid, amount: amount)
                successMessage = "Repayment successful"
            } catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
}
