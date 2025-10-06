//
//  WalletService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import Foundation
import Alamofire

class WalletService {
    static let shared = WalletService()
    
    private init() {}
    
    // MARK: - Get Dashboard Data
    func getDashboard(completion: @escaping (Result<DashboardResponse, Error>) -> Void) {
        guard let token = KeychainManager.shared.getToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        AF.request(
            "\(APIConstants.baseURL)/dashboard",
            method: .get,
            headers: headers
        )
        .validate()
        .responseData { response in
            // Log raw response for debugging
            if let data = response.data {
                if let json = String(data: data, encoding: .utf8) {
                    print("📦 API Response [/dashboard]: \(json)")
                }
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(WalletAPIResponse<DashboardData>.self, from: data)
                    
                    if apiResponse.success {
                        completion(.success(DashboardResponse(
                            user: apiResponse.data.user,
                            wallets: apiResponse.data.wallets,
                            recentTransactions: apiResponse.data.recentTransactions,
                            statistics: apiResponse.data.statistics
                        )))
                    } else {
                        completion(.failure(NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Unknown error"])))
                    }
                } catch {
                    print("❌ Dashboard decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Dashboard API Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get All Wallets (Fallback)
    func getWallets(completion: @escaping (Result<[Wallet], Error>) -> Void) {
        guard let token = KeychainManager.shared.getToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        AF.request(
            "\(APIConstants.baseURL)/wallets",
            method: .get,
            headers: headers
        )
        .validate()
        .responseData { response in
            if let data = response.data {
                if let json = String(data: data, encoding: .utf8) {
                    print("📦 API Response [/wallets]: \(json)")
                }
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(WalletAPIResponse<[Wallet]>.self, from: data)
                    
                    if apiResponse.success {
                        completion(.success(apiResponse.data))
                    } else {
                        completion(.failure(NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Unknown error"])))
                    }
                } catch {
                    print("❌ Wallets decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Wallets API Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Wallet by Currency
    func getWallet(currency: String, completion: @escaping (Result<Wallet, Error>) -> Void) {
        guard let token = KeychainManager.shared.getToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        AF.request(
            "\(APIConstants.baseURL)/wallets/\(currency)",
            method: .get,
            headers: headers
        )
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(WalletAPIResponse<Wallet>.self, from: data)
                    
                    if apiResponse.success {
                        completion(.success(apiResponse.data))
                    } else {
                        completion(.failure(NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Unknown error"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Wallet API Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Dashboard Response Models
struct DashboardResponse: Codable, Sendable {
    let user: User
    let wallets: [Wallet]
    let recentTransactions: [Transaction]
    let statistics: DashboardStatistics
}

struct DashboardData: Codable, Sendable {
    let user: User
    let wallets: [Wallet]
    let recentTransactions: [Transaction]
    let statistics: DashboardStatistics
    
    enum CodingKeys: String, CodingKey {
        case user
        case wallets
        case recentTransactions = "recent_transactions"
        case statistics = "stats"  // Changed from "statistics" to "stats"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decode(User.self, forKey: .user)
        self.wallets = try container.decode([Wallet].self, forKey: .wallets)
        self.recentTransactions = try container.decode([Transaction].self, forKey: .recentTransactions)
        self.statistics = try container.decode(DashboardStatistics.self, forKey: .statistics)
    }
}

struct DashboardStatistics: Codable, Sendable {
    let totalDeposits: String
    let totalWithdrawals: String
    let totalTransfers: String
    let transactionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalDeposits = "total_deposits"
        case totalWithdrawals = "total_withdrawals"
        case totalTransfers = "total_transfers"
        case transactionCount = "transaction_count"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle both String and Int types
        if let depositsString = try? container.decode(String.self, forKey: .totalDeposits) {
            self.totalDeposits = depositsString
        } else if let depositsInt = try? container.decode(Int.self, forKey: .totalDeposits) {
            self.totalDeposits = String(depositsInt)
        } else {
            self.totalDeposits = "0"
        }
        
        if let withdrawalsString = try? container.decode(String.self, forKey: .totalWithdrawals) {
            self.totalWithdrawals = withdrawalsString
        } else if let withdrawalsInt = try? container.decode(Int.self, forKey: .totalWithdrawals) {
            self.totalWithdrawals = String(withdrawalsInt)
        } else {
            self.totalWithdrawals = "0"
        }
        
        if let transfersString = try? container.decode(String.self, forKey: .totalTransfers) {
            self.totalTransfers = transfersString
        } else if let transfersInt = try? container.decode(Int.self, forKey: .totalTransfers) {
            self.totalTransfers = String(transfersInt)
        } else {
            self.totalTransfers = "0"
        }
        
        self.transactionCount = try container.decode(Int.self, forKey: .transactionCount)
    }
}

// MARK: - Local API Response (just for WalletService)
private struct WalletAPIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let message: String?
    let data: T
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.data = try container.decode(T.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case success, message, data
    }
}
