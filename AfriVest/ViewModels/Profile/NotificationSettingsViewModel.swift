//
//  NotificationSettingsViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//


import SwiftUI
import Combine

@MainActor
class NotificationSettingsViewModel: ObservableObject {
    @Published var pushEnabled = true
    @Published var emailEnabled = true
    @Published var smsEnabled = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        setupObservers()
    }
    
    private func loadSettings() {
        pushEnabled = UserDefaults.standard.bool(forKey: "notification_push_enabled")
        emailEnabled = UserDefaults.standard.bool(forKey: "notification_email_enabled")
        smsEnabled = UserDefaults.standard.bool(forKey: "notification_sms_enabled")
    }
    
    private func setupObservers() {
        $pushEnabled
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "notification_push_enabled") }
            .store(in: &cancellables)
        
        $emailEnabled
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "notification_email_enabled") }
            .store(in: &cancellables)
        
        $smsEnabled
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "notification_sms_enabled") }
            .store(in: &cancellables)
    }
}
