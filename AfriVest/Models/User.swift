//
//  User.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//
import Foundation

struct User: Codable, Identifiable {
let id: Int
let name: String
let email: String
let phoneNumber: String
let role: String
let status: String
let avatarUrl: String?
let emailVerifiedAt: String?
let createdAt: String
let updatedAt: String?


enum CodingKeys: String, CodingKey {
    case id, name, email, role, status
    case phoneNumber = "phone_number"
    case avatarUrl = "avatar_url"
    case emailVerifiedAt = "email_verified_at"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
}

var isActive: Bool {
    return status == "active"
}

var isVerified: Bool {
    return emailVerifiedAt != nil
}

}
