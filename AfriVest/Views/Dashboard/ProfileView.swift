//
//  ProfileView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI
import Alamofire

struct ProfileView: View {
    @State private var showLogoutConfirmation = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Text("Profile")
                        .h1Style()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.xl)
                    
                    Text("Your profile settings will appear here")
                        .bodyRegularStyle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                        .frame(height: Spacing.xxl)
                    
                    // Logout Button
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .font(.system(size: 20))
                            
                            Text("Logout")
                                .font(AppFont.button())
                        }
                        .foregroundColor(.errorRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: Spacing.buttonHeight)
                        .background(Color.inputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                .stroke(Color.errorRed, lineWidth: Spacing.borderMedium)
                        )
                        .cornerRadius(Spacing.radiusMedium)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.screenHorizontal)
            }
        }
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
    
    private func logout() {
        Task {
            do {
                // Call logout API
                let _: MessageResponse = try await APIClient.shared.request(
                    APIConstants.Endpoints.logout,
                    method: .post,
                    requiresAuth: true
                )
                
                await MainActor.run {
                    // Clear all stored data after successful API call
                    KeychainManager.shared.clearAll()
                    
                    // Reset to login screen
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                }
                
            } catch {
                await MainActor.run {
                    // Even if API call fails, still logout locally
                    KeychainManager.shared.clearAll()
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
    }
}
