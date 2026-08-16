//
//  QrService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import Foundation
import Alamofire

struct QrData: Codable, Sendable {
    let uuid: String
    let name: String?
    let phone_number: String?
    
    enum CodingKeys: String, CodingKey { case uuid, name, phone_number }
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try c.decode(String.self, forKey: .uuid)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        phone_number = try c.decodeIfPresent(String.self, forKey: .phone_number)
    }
}

class QrService {
    static let shared = QrService()
    private let apiClient = APIClient.shared
    private init() {}
    
    func getMyQr() async throws -> QrData {
        try await apiClient.request("/users/qr", method: .get, parameters: nil, requiresAuth: true)
    }
}
