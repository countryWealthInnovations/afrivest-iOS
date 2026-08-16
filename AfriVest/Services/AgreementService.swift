//
//  AgreementService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import Foundation
import Alamofire

struct InvestmentAgreementData: Codable, Sendable, Identifiable {
    var id: String { version }
    let version: String
    let title: String
    let body: String
    let accepted: Bool
    
    enum CodingKeys: String, CodingKey { case version, title, body, accepted }
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        version = (try? c.decode(String.self, forKey: .version)) ?? ""
        title = (try? c.decode(String.self, forKey: .title)) ?? "Investment Agreement"
        body = (try? c.decode(String.self, forKey: .body)) ?? ""
        accepted = (try? c.decode(Bool.self, forKey: .accepted)) ?? false
    }
}

class AgreementService {
    static let shared = AgreementService()
    private let apiClient = APIClient.shared
    private init() {}
    
    func getAgreement() async throws -> InvestmentAgreementData {
        try await apiClient.request("/investment-agreement", method: .get, parameters: nil, requiresAuth: true)
    }
    
    func accept() async throws {
        let _: EmptyDataResponse = try await apiClient.request(
            "/investment-agreement/accept", method: .post, parameters: [:], requiresAuth: true)
    }
}
