//
//  AdvisorService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import Foundation
import Alamofire

class AdvisorService {
    static let shared = AdvisorService()
    private let api = APIClient.shared
    private init() {}

    func list() async throws -> [Advisor] {
        try await api.request("/advisors", method: .get, parameters: nil, requiresAuth: true)
    }
    func detail(id: Int) async throws -> Advisor {
        try await api.request("/advisors/\(id)", method: .get, parameters: nil, requiresAuth: true)
    }
    func myBookings() async throws -> [AdvisorBookingItem] {
        try await api.request("/advisors/bookings/my", method: .get, parameters: nil, requiresAuth: true)
    }
    func book(id: Int, scheduledAt: String, notes: String?) async throws -> AdvisorBookingItem {
        var params: [String: Any] = ["scheduled_at": scheduledAt]
        if let notes = notes { params["notes"] = notes }
        let wrapper: BookingWrapper = try await api.request("/advisors/\(id)/book", method: .post, parameters: params, requiresAuth: true)
        return wrapper.booking
    }
}
