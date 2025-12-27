//
//  EditProfileViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//


import SwiftUI
import Combine
import Alamofire

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var phoneNumber = ""
    @Published var avatarUrl: String?
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var originalName = ""
    private var originalPhone = ""
    private let profileService = ProfileService.shared
    
    var hasChanges: Bool {
        name != originalName || 
        phoneNumber != originalPhone || 
        selectedImage != nil
    }
    
    func loadProfile() {
        profileService.getProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.name = profile.name
                    self?.originalName = profile.name
                    self?.phoneNumber = profile.phoneNumber ?? ""
                    self?.originalPhone = profile.phoneNumber ?? ""
                    self?.avatarUrl = profile.avatarUrl
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateProfile(completion: @escaping () -> Void) {
        guard hasChanges else {
            completion()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Upload avatar first if changed
                if let image = selectedImage {
                    let response: AvatarUploadResponse = try await APIClient.shared.upload(
                        APIConstants.Endpoints.uploadAvatar,
                        method: .post,
                        image: image,
                        imageKey: "avatar",
                        requiresAuth: true
                    )
                    avatarUrl = response.avatarUrl
                }
                
                // Update profile details
                if name != originalName || phoneNumber != originalPhone {
                    var params: [String: Any] = [:]
                    if name != originalName {
                        params["name"] = name
                    }
                    if phoneNumber != originalPhone {
                        params["phone_number"] = phoneNumber
                    }
                    
                    let _: UpdateProfileResponse = try await APIClient.shared.request(
                        APIConstants.Endpoints.profile,
                        method: .put,
                        parameters: params,
                        requiresAuth: true
                    )
                }
                
                // Update cache
                profileService.forceRefresh { _ in }
                
                self.isLoading = false
                completion()
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func deleteAvatar() {
        Task {
            do {
                let _: MessageResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.deleteAvatar,
                    method: .delete,
                    requiresAuth: true
                )
                
                avatarUrl = nil
                selectedImage = nil
                profileService.forceRefresh { _ in }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func getInitials() -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
}

// Response Models
struct AvatarUploadResponse: Codable, Sendable {
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
    }
}

struct UpdateProfileResponse: Codable, Sendable {
    let id: Int
    let name: String
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case phoneNumber = "phone_number"
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
    }
}
