//
//  AdvisorViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class AdvisorViewModel: ObservableObject {
    @Published var advisors: [Advisor] = []
    @Published var detail: Advisor?
    @Published var bookings: [AdvisorBookingItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var justBooked: AdvisorBookingItem?

    private let service = AdvisorService.shared

    func loadAdvisors() {
        isLoading = true
        Task {
            do { advisors = try await service.list() }
            catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    func loadDetail(id: Int) {
        isLoading = true
        Task {
            do { detail = try await service.detail(id: id) }
            catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    func loadBookings() {
        isLoading = true
        Task {
            do { bookings = try await service.myBookings() }
            catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
    func book(id: Int, slot: AdvisorSlot, notes: String?) {
        isLoading = true
        Task {
            do { justBooked = try await service.book(id: id, scheduledAt: slot.datetime, notes: notes) }
            catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
}