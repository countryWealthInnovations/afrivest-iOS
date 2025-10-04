//
//  APIClient.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import Foundation
import SwiftUI
import Alamofire

class APIClient: @unchecked Sendable {
    static let shared = APIClient()
    
    private let session: Session
    private let keychainManager = KeychainManager.shared
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConstants.requestTimeout
        configuration.timeoutIntervalForResource = APIConstants.resourceTimeout
        
        session = Session(configuration: configuration)
    }
    
    // MARK: - Generic Request
    func request<T: Decodable & Sendable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        
        let url = APIConstants.baseURL + endpoint
        
        var finalHeaders = headers ?? HTTPHeaders()
        finalHeaders.add(name: APIConstants.Headers.contentType, value: APIConstants.Headers.applicationJSON)
        finalHeaders.add(name: APIConstants.Headers.accept, value: APIConstants.Headers.applicationJSON)
        
        if requiresAuth, let token = keychainManager.getToken() {
            finalHeaders.add(name: APIConstants.Headers.authorization, value: "Bearer \(token)")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached {
                self.session.request(
                    url,
                    method: method,
                    parameters: parameters,
                    encoding: encoding,
                    headers: finalHeaders
                )
                .validate()
                .responseDecodable(of: APIResponse<T>.self) { response in
                    // Log raw response for debugging
                    if let data = response.data {
                        if let json = String(data: data, encoding: .utf8) {
                            print("📦 API Response [\(endpoint)]: \(json)")
                        }
                    }
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.success {
                            print("✅ Success: \(endpoint)")
                            continuation.resume(returning: apiResponse.data)
                        } else {
                            print("❌ API Error: \(apiResponse.message ?? "Unknown error")")
                            let error = APIError.serverError(apiResponse.message ?? "Unknown error")
                            continuation.resume(throwing: error)
                        }
                        
                    case .failure(let error):
                        print("❌ Network Error: \(error.localizedDescription)")
                        if let statusCode = response.response?.statusCode {
                            print("📍 Status Code: \(statusCode)")
                        }
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
            }
        }
    }
    
    // MARK: - Multipart Upload
    func upload<T: Decodable & Sendable>(
        _ endpoint: String,
        method: HTTPMethod = .post,
        parameters: [String: Any]? = nil,
        image: UIImage? = nil,
        imageKey: String = "image",
        requiresAuth: Bool = true
    ) async throws -> T {
        
        let url = APIConstants.baseURL + endpoint
        
        var headers = HTTPHeaders()
        if requiresAuth, let token = keychainManager.getToken() {
            headers.add(name: APIConstants.Headers.authorization, value: "Bearer \(token)")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached {
                self.session.upload(
                    multipartFormData: { multipartFormData in
                        // Add image if provided
                        if let image = image,
                           let imageData = image.jpegData(compressionQuality: 0.8) {
                            multipartFormData.append(
                                imageData,
                                withName: imageKey,
                                fileName: "image.jpg",
                                mimeType: "image/jpeg"
                            )
                        }
                        
                        // Add other parameters
                        if let parameters = parameters {
                            for (key, value) in parameters {
                                if let data = "\(value)".data(using: .utf8) {
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                        }
                    },
                    to: url,
                    method: method,
                    headers: headers
                )
                .validate()
                .responseDecodable(of: APIResponse<T>.self) { response in
                    // Log raw response
                    if let data = response.data {
                        if let json = String(data: data, encoding: .utf8) {
                            print("📦 Upload Response [\(endpoint)]: \(json)")
                        }
                    }
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.success {
                            print("✅ Upload Success: \(endpoint)")
                            continuation.resume(returning: apiResponse.data)
                        } else {
                            print("❌ Upload Error: \(apiResponse.message ?? "Upload failed")")
                            let error = APIError.serverError(apiResponse.message ?? "Upload failed")
                            continuation.resume(throwing: error)
                        }
                        
                    case .failure(let error):
                        print("❌ Upload Network Error: \(error.localizedDescription)")
                        if let statusCode = response.response?.statusCode {
                            print("📍 Status Code: \(statusCode)")
                        }
                        continuation.resume(throwing: self.handleError(error, response: response.response))
                    }
                }
            }
        }
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: AFError, response: HTTPURLResponse?) -> APIError {
        if let statusCode = response?.statusCode {
            print("⚠️ HTTP Status Code: \(statusCode)")
            switch statusCode {
            case APIConstants.StatusCodes.unauthorized:
                NotificationCenter.default.post(name: AppConstants.Notifications.tokenExpired, object: nil)
                return .unauthorized
            case APIConstants.StatusCodes.forbidden:
                return .forbidden
            case APIConstants.StatusCodes.notFound:
                return .notFound
            case APIConstants.StatusCodes.validationError:
                return .validationError("Please check your input")
            case APIConstants.StatusCodes.tooManyRequests:
                return .rateLimitExceeded
            case APIConstants.StatusCodes.serverError:
                return .serverError("Server error. Please try again later.")
            default:
                break
            }
        }
        
        if let underlyingError = error.underlyingError as? URLError {
            print("⚠️ URLError: \(underlyingError.code)")
            switch underlyingError.code {
            case .notConnectedToInternet:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            default:
                return .networkError(underlyingError.localizedDescription)
            }
        }
        
        return .unknown(error.localizedDescription)
    }
}

// MARK: - API Response Model
struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let message: String?
    let data: T
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        // Try to decode data, if it fails return empty object
        if let dataValue = try? container.decode(T.self, forKey: .data) {
            data = dataValue
        } else {
            // For cases where data might be null/missing
            throw DecodingError.keyNotFound(
                CodingKeys.data,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Data key not found or null"
                )
            )
        }
    }
}

// MARK: - API Error
enum APIError: LocalizedError, Sendable {
    case unauthorized
    case forbidden
    case notFound
    case validationError(String)
    case serverError(String)
    case rateLimitExceeded
    case noInternetConnection
    case timeout
    case networkError(String)
    case decodingError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Your session has expired. Please login again."
        case .forbidden:
            return "You don't have permission to perform this action."
        case .notFound:
            return "The requested resource was not found."
        case .validationError(let message):
            return message
        case .serverError(let message):
            return message
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        case .timeout:
            return "Request timed out. Please try again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError:
            return "Failed to process server response."
        case .unknown(let message):
            return message
        }
    }
}
