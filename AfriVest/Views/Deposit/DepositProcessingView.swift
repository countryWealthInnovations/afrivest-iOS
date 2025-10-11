//
//  DepositProcessingView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 11/10/2025.
//

import SwiftUI

struct DepositProcessingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDashboard = false
    
    let reference: String
    let amount: String
    let currency: String
    
    var body: some View {
        ZStack {
            Color.backgroundDark1.ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Animated Icon
                ZStack {
                    Circle()
                        .fill(Color.primaryGold.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryGold)
                }
                
                // Title
                Text("Payment Submitted!")
                    .h1Style()
                    .multilineTextAlignment(.center)
                
                // Message
                VStack(spacing: Spacing.sm) {
                    Text("We're processing your deposit")
                        .bodyLargeStyle()
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("You'll receive a notification when your account is credited")
                        .bodyRegularStyle()
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
                
                // Transaction Details
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Text("Reference")
                            .bodyRegularStyle()
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text(reference)
                            .bodyRegularStyle()
                            .foregroundColor(.textPrimary)
                    }
                    
                    Divider()
                        .background(Color.borderDefault)
                    
                    HStack {
                        Text("Amount")
                            .bodyRegularStyle()
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text("\(amount) \(currency)")
                            .bodyLargeStyle()
                            .foregroundColor(.primaryGold)
                    }
                }
                .padding(Spacing.md)
                .background(Color.inputBackground)
                .cornerRadius(Spacing.radiusMedium)
                
                Spacer()
                
                // Dismiss Button
                PrimaryButton(
                    title: "Done",
                    action: {
                        navigateToDashboard = true
                    },
                    isLoading: false,
                    isEnabled: true
                )
            }
            .padding(Spacing.screenHorizontal)
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $navigateToDashboard) {
            DashboardView()
        }
    }
}
