//
//  DepositService.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import Foundation
import Alamofire

class DepositService {
    
    static let shared = DepositService()
    
    // MARK: - Initiate SDK Deposit
    
    func initiateSDKDeposit(amount: Double, currency: String, completion: @escaping (Result<SDKInitiateResponse, Error>) -> Void) {
        
        guard let token = KeychainManager.shared.getToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let url = APIConstants.baseURL + "/deposits/sdk/initiate"
        let parameters: [String: Any] = [
            "amount": amount,
            "currency": currency
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let apiResponse = try decoder.decode(DepositAPIResponse<SDKInitiateResponse>.self, from: data)
                        
                        if apiResponse.success {
                            completion(.success(apiResponse.data))
                        } else {
                            completion(.failure(NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Unknown error"])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Verify SDK Deposit
    
    func verifySDKDeposit(transactionId: Int, flwRef: String, status: String, completion: @escaping (Result<Transaction, Error>) -> Void) {
        
        guard let token = KeychainManager.shared.getToken() else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let url = APIConstants.baseURL + "/deposits/sdk/verify"
        let parameters: [String: Any] = [
            "transaction_id": transactionId,
            "flw_ref": flwRef,
            "status": status
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let apiResponse = try decoder.decode(DepositAPIResponse<VerifyResponse>.self, from: data)
                        
                        if apiResponse.success {
                            completion(.success(apiResponse.data.transaction))
                        } else {
                            completion(.failure(NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Verification failed"])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// MARK: - Local API Response (just for DepositService)
private struct DepositAPIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let message: String?
    let data: T
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        data = try container.decode(T.self, forKey: .data)
    }
    
    enum CodingKeys: String, CodingKey {
        case success, message, data
    }
}

// MARK: - Models

struct SDKInitiateResponse: Codable, Sendable {
    let transactionId: Int
    let txRef: String
    let amount: Double
    let currency: String
    let user: UserInfo
    let sdkConfig: SDKConfig
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case txRef = "tx_ref"
        case amount, currency, user
        case sdkConfig = "sdk_config"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionId = try container.decode(Int.self, forKey: .transactionId)
        txRef = try container.decode(String.self, forKey: .txRef)
        amount = try container.decode(Double.self, forKey: .amount)
        currency = try container.decode(String.self, forKey: .currency)
        user = try container.decode(UserInfo.self, forKey: .user)
        sdkConfig = try container.decode(SDKConfig.self, forKey: .sdkConfig)
    }
}

struct UserInfo: Codable, Sendable {
    let email: String
    let name: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case email, name
        case phoneNumber = "phone_number"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
    }
}

struct SDKConfig: Codable, Sendable {
    let publicKey: String
    let encryptionKey: String
    
    enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case encryptionKey = "encryption_key"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        publicKey = try container.decode(String.self, forKey: .publicKey)
        encryptionKey = try container.decode(String.self, forKey: .encryptionKey)
    }
}

struct VerifyResponse: Codable, Sendable {
    let transaction: Transaction
    let wallet: WalletInfo?
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transaction = try container.decode(Transaction.self, forKey: .transaction)
        wallet = try container.decodeIfPresent(WalletInfo.self, forKey: .wallet)
    }
    
    enum CodingKeys: String, CodingKey {
        case transaction, wallet
    }
}

struct WalletInfo: Codable, Sendable {
    let currency: String
    let balance: String
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decode(String.self, forKey: .currency)
        balance = try container.decode(String.self, forKey: .balance)
    }
    
    enum CodingKeys: String, CodingKey {
        case currency, balance
    }
}
