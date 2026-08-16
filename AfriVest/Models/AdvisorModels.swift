//
//  AdvisorModels.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import Foundation

struct Advisor: Codable, Identifiable, Sendable {
    let id: Int
    let displayName: String
    let title: String?
    let expertise: String?
    let bookingFee: String?
    let bookingFeeCurrency: String?
    let sessionDurationMinutes: Int?
    let avatarUrl: String?
    let bio: String?
    let slots: [AdvisorSlot]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, expertise, bio, slots
        case displayName = "display_name"
        case bookingFee = "booking_fee"
        case bookingFeeCurrency = "booking_fee_currency"
        case sessionDurationMinutes = "session_duration_minutes"
        case avatarUrl = "avatar_url"
    }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        displayName = (try? c.decode(String.self, forKey: .displayName)) ?? ""
        title = try c.decodeIfPresent(String.self, forKey: .title)
        expertise = try c.decodeIfPresent(String.self, forKey: .expertise)
        bookingFee = try c.decodeIfPresent(String.self, forKey: .bookingFee)
        bookingFeeCurrency = try c.decodeIfPresent(String.self, forKey: .bookingFeeCurrency)
        sessionDurationMinutes = try c.decodeIfPresent(Int.self, forKey: .sessionDurationMinutes)
        avatarUrl = try c.decodeIfPresent(String.self, forKey: .avatarUrl)
        bio = try c.decodeIfPresent(String.self, forKey: .bio)
        slots = try c.decodeIfPresent([AdvisorSlot].self, forKey: .slots)
    }
}

struct AdvisorSlot: Codable, Identifiable, Sendable {
    var id: String { datetime }
    let date: String
    let start: String
    let end: String
    let datetime: String
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        date = try c.decode(String.self, forKey: .date)
        start = try c.decode(String.self, forKey: .start)
        end = try c.decode(String.self, forKey: .end)
        datetime = try c.decode(String.self, forKey: .datetime)
    }
    enum CodingKeys: String, CodingKey { case date, start, end, datetime }
}

struct AdvisorBookingItem: Decodable, Identifiable, Sendable {
    var id: String { uuid }
    let uuid: String
    let reference: String
    let scheduledAt: String
    let durationMinutes: Int
    let feePaid: String?
    let feeCurrency: String?
    let status: String
    let meetingLink: String?
    let advisorName: String?
    let clientName: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid, reference, status, advisor
        case scheduledAt = "scheduled_at"
        case durationMinutes = "duration_minutes"
        case feePaid = "fee_paid"
        case feeCurrency = "fee_currency"
        case meetingLink = "meeting_link"
        case clientName = "client_name"
    }
    struct Mini: Decodable { let display_name: String? }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        uuid = try c.decode(String.self, forKey: .uuid)
        reference = (try? c.decode(String.self, forKey: .reference)) ?? ""
        scheduledAt = (try? c.decode(String.self, forKey: .scheduledAt)) ?? ""
        durationMinutes = (try? c.decode(Int.self, forKey: .durationMinutes)) ?? 30
        feePaid = try c.decodeIfPresent(String.self, forKey: .feePaid)
        feeCurrency = try c.decodeIfPresent(String.self, forKey: .feeCurrency)
        status = (try? c.decode(String.self, forKey: .status)) ?? ""
        meetingLink = try c.decodeIfPresent(String.self, forKey: .meetingLink)
        advisorName = (try? c.decodeIfPresent(Mini.self, forKey: .advisor))?.display_name
        clientName = try c.decodeIfPresent(String.self, forKey: .clientName)
    }
}

struct BookingWrapper: Decodable, Sendable {
    let booking: AdvisorBookingItem
    enum CodingKeys: String, CodingKey { case booking }
    nonisolated init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        booking = try c.decode(AdvisorBookingItem.self, forKey: .booking)
    }
}
