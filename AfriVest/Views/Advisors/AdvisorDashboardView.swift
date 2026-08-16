//
//  AdvisorDashboardView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import SwiftUI
import Alamofire
import Combine

// MARK: - DTOs

struct DashProfile: Codable, Sendable {
    let id: Int
    let displayName: String
    let title: String?
    let bio: String?
    let expertise: String?
    let bookingFee: String?
    let bookingFeeCurrency: String?
    let sessionDurationMinutes: Int?
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, bio, expertise
        case displayName = "display_name"
        case bookingFee = "booking_fee"
        case bookingFeeCurrency = "booking_fee_currency"
        case sessionDurationMinutes = "session_duration_minutes"
        case isActive = "is_active"
    }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        displayName = (try? c.decode(String.self, forKey: .displayName)) ?? ""
        title = try c.decodeIfPresent(String.self, forKey: .title)
        bio = try c.decodeIfPresent(String.self, forKey: .bio)
        expertise = try c.decodeIfPresent(String.self, forKey: .expertise)
        if let s = try? c.decode(String.self, forKey: .bookingFee) { bookingFee = s }
        else if let dd = try? c.decode(Double.self, forKey: .bookingFee) { bookingFee = String(dd) }
        else { bookingFee = nil }
        bookingFeeCurrency = try c.decodeIfPresent(String.self, forKey: .bookingFeeCurrency)
        sessionDurationMinutes = try c.decodeIfPresent(Int.self, forKey: .sessionDurationMinutes)
        isActive = (try? c.decode(Bool.self, forKey: .isActive)) ?? true
    }
}

struct DashAvailability: Decodable, Sendable {
    let id: Int?
    let dayOfWeek: Int
    let startTime: String
    let endTime: String
    enum CodingKeys: String, CodingKey {
        case id
        case dayOfWeek = "day_of_week"
        case startTime = "start_time"
        case endTime = "end_time"
    }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        dayOfWeek = try c.decode(Int.self, forKey: .dayOfWeek)
        startTime = try c.decode(String.self, forKey: .startTime)
        endTime = try c.decode(String.self, forKey: .endTime)
    }
}

struct DashDateBlock: Decodable, Sendable, Identifiable {
    let id: Int
    let date: String
    let reason: String?
    enum CodingKeys: String, CodingKey { case id, date, reason }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        date = try c.decode(String.self, forKey: .date)
        reason = try c.decodeIfPresent(String.self, forKey: .reason)
    }
}

struct AdvisorDashboardData: Decodable, Sendable {
    let profile: DashProfile
    let availability: [DashAvailability]
    let dateBlocks: [DashDateBlock]
    let upcomingBookings: [AdvisorBookingItem]
    enum CodingKeys: String, CodingKey {
        case profile, availability
        case dateBlocks = "date_blocks"
        case upcomingBookings = "upcoming_bookings"
    }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        profile = try c.decode(DashProfile.self, forKey: .profile)
        availability = (try? c.decode([DashAvailability].self, forKey: .availability)) ?? []
        dateBlocks = (try? c.decode([DashDateBlock].self, forKey: .dateBlocks)) ?? []
        upcomingBookings = (try? c.decode([AdvisorBookingItem].self, forKey: .upcomingBookings)) ?? []
    }
}

// Editable slot for the UI
struct EditableSlot: Identifiable {
    let id = UUID()
    var dayOfWeek: Int
    var start: String
    var end: String
}

// MARK: - View Model

@MainActor
final class AdvisorDashboardViewModel: ObservableObject {
    @Published var profile: DashProfile?
    @Published var slots: [EditableSlot] = []
    @Published var blocks: [DashDateBlock] = []
    @Published var upcoming: [AdvisorBookingItem] = []
    @Published var isLoading = false
    @Published var message: String?
    @Published var errorMessage: String?
    
    private let api = APIClient.shared
    
    func load() {
        isLoading = true
        Task {
            do {
                let data: AdvisorDashboardData = try await api.request(
                    "/advisor/dashboard", method: .get, parameters: nil, requiresAuth: true)
                profile = data.profile
                slots = data.availability.map { EditableSlot(dayOfWeek: $0.dayOfWeek, start: $0.startTime, end: $0.endTime) }
                blocks = data.dateBlocks
                upcoming = data.upcomingBookings
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func addSlot(day: Int) {
        slots.append(EditableSlot(dayOfWeek: day, start: "09:00", end: "10:00"))
    }
    func removeSlot(_ slot: EditableSlot) {
        slots.removeAll { $0.id == slot.id }
    }
    
    func saveAvailability() {
        isLoading = true
        let payload = slots.map { ["day_of_week": $0.dayOfWeek, "start_time": $0.start, "end_time": $0.end] as [String: Any] }
        Task {
            do {
                let _: EmptyDataResponse = try await api.request(
                    "/advisor/availability", method: .put,
                    parameters: ["slots": payload], requiresAuth: true)
                message = "Availability updated"
                load()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func blockDate(_ date: String) {
        guard !date.isEmpty else { return }
        Task {
            do {
                let _: EmptyDataResponse = try await api.request(
                    "/advisor/date-blocks", method: .post,
                    parameters: ["date": date], requiresAuth: true)
                message = "Date blocked"
                load()
            } catch { errorMessage = error.localizedDescription }
        }
    }
    
    func unblock(_ id: Int) {
        Task {
            do {
                let _: EmptyDataResponse = try await api.request(
                    "/advisor/date-blocks/\(id)", method: .delete,
                    parameters: nil, requiresAuth: true)
                message = "Date block removed"
                load()
            } catch { errorMessage = error.localizedDescription }
        }
    }
}

// MARK: - View

struct AdvisorDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AdvisorDashboardViewModel()
    @State private var newBlockDate = ""
    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let p = viewModel.profile {
                            Text(p.displayName).font(.title3).bold().foregroundColor(.white)
                            Text("Fee \(p.bookingFeeCurrency ?? "") \(p.bookingFee ?? "0") • \(p.sessionDurationMinutes ?? 30) min")
                                .font(.caption).foregroundColor(Color.primaryGold)
                        }
                        
                        Text("Upcoming bookings").font(.headline).foregroundColor(.white)
                        if viewModel.upcoming.isEmpty {
                            Text("None").font(.caption).foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.upcoming) { b in
                                Text("\(b.scheduledAt.prefix(16).replacingOccurrences(of: "T", with: " "))  •  \(b.clientName ?? "Client")")
                                    .font(.caption).foregroundColor(Color(white: 0.85))
                            }
                        }
                        
                        Text("Weekly availability").font(.headline).foregroundColor(.white).padding(.top, 8)
                        ForEach(0..<7, id: \.self) { day in
                            availabilityDay(day)
                        }
                        
                        Button(action: { viewModel.saveAvailability() }) {
                            Text("Save Availability").bold().frame(maxWidth: .infinity).padding()
                                .background(Color.primaryGold).foregroundColor(.black).cornerRadius(10)
                        }.padding(.top, 8)
                        
                        Text("Blocked dates").font(.headline).foregroundColor(.white).padding(.top, 8)
                        ForEach(viewModel.blocks) { block in
                            HStack {
                                Text(block.date).foregroundColor(Color(white: 0.85))
                                Spacer()
                                Button(action: { viewModel.unblock(block.id) }) {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                }
                            }
                        }
                        HStack {
                            TextField("YYYY-MM-DD", text: $newBlockDate)
                                .padding(8).background(Color(white: 0.15)).cornerRadius(8).foregroundColor(.white)
                            Button("Block") { viewModel.blockDate(newBlockDate); newBlockDate = "" }
                                .foregroundColor(Color.primaryGold)
                        }
                    }
                    .padding()
                }
                if viewModel.isLoading { ProgressView().tint(Color.primaryGold) }
            }
            .navigationTitle("Advisor Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() }.foregroundColor(Color.primaryGold) }
            }
            .onAppear { viewModel.load() }
            .alert("Done", isPresented: Binding(get: { viewModel.message != nil }, set: { if !$0 { viewModel.message = nil } })) {
                Button("OK") { viewModel.message = nil }
            } message: { Text(viewModel.message ?? "") }
                .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
                    Button("OK") { viewModel.errorMessage = nil }
                } message: { Text(viewModel.errorMessage ?? "") }
        }
    }
    
    private func availabilityDay(_ day: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(dayNames[day]).font(.subheadline).bold().foregroundColor(.white)
                Spacer()
                Button("+ Add") { viewModel.addSlot(day: day) }.font(.caption).foregroundColor(Color.primaryGold)
            }
            ForEach(viewModel.slots.filter { $0.dayOfWeek == day }) { slot in
                if let idx = viewModel.slots.firstIndex(where: { $0.id == slot.id }) {
                    HStack(spacing: 8) {
                        TextField("HH:mm", text: $viewModel.slots[idx].start)
                            .padding(6).background(Color(white: 0.15)).cornerRadius(6).foregroundColor(.white)
                        Text("to").foregroundColor(.gray)
                        TextField("HH:mm", text: $viewModel.slots[idx].end)
                            .padding(6).background(Color(white: 0.15)).cornerRadius(6).foregroundColor(.white)
                        Button(action: { viewModel.removeSlot(slot) }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
