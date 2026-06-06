//
//  NotificationSettingsViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//


import SwiftUI
import Combine
import Alamofire

class NotificationSettingsViewModel: ObservableObject {
    @Published var pushEnabled  = true
    @Published var emailEnabled = true
    @Published var smsEnabled   = false
    @Published var isLoading    = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var isInitialLoad = true
    
    init() {
        loadFromLocal()
        Task { await fetchFromAPI() }
        setupObservers()
    }
    
    private func loadFromLocal() {
        pushEnabled  = UserDefaults.standard.object(forKey: "notif_push")  as? Bool ?? true
        emailEnabled = UserDefaults.standard.object(forKey: "notif_email") as? Bool ?? true
        smsEnabled   = UserDefaults.standard.object(forKey: "notif_sms")   as? Bool ?? false
    }
    
    func fetchFromAPI() async {
        await MainActor.run { isLoading = true }
        do {
            let response: NotifSettingsResponse = try await APIClient.shared.request(
                "/profile/notification-settings",
                method: .get,
                requiresAuth: true
            )
            await MainActor.run {
                isInitialLoad = true
                pushEnabled   = response.data.push_enabled
                emailEnabled  = response.data.email_enabled
                smsEnabled    = response.data.sms_enabled
                isLoading     = false
                isInitialLoad = false
            }
            saveToLocal()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading    = false
                isInitialLoad = false
            }
        }
    }
    
    private func saveToLocal() {
        UserDefaults.standard.set(pushEnabled,  forKey: "notif_push")
        UserDefaults.standard.set(emailEnabled, forKey: "notif_email")
        UserDefaults.standard.set(smsEnabled,   forKey: "notif_sms")
    }
    
    private func setupObservers() {
        Publishers.MergeMany(
            $pushEnabled.dropFirst().map  { _ in () },
            $emailEnabled.dropFirst().map { _ in () },
            $smsEnabled.dropFirst().map   { _ in () }
        )
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            guard let self, !self.isInitialLoad else { return }
            Task { await self.syncToAPI() }
        }
        .store(in: &cancellables)
    }
    
    private func syncToAPI() async {
        saveToLocal()
        do {
            let body: [String: Any] = [
                "push_enabled":  pushEnabled,
                "email_enabled": emailEnabled,
                "sms_enabled":   smsEnabled,
            ]
            let _: NotifEmpty = try await APIClient.shared.request(
                "/profile/notification-settings",
                method: .put,
                parameters: body,
                requiresAuth: true
            )
        } catch {
            await MainActor.run { errorMessage = "Failed to save settings" }
        }
    }
}
