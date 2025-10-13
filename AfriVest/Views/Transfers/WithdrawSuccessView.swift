//
//  WithdrawSuccessView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 13/10/2025.
//

import SwiftUI

struct WithdrawSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDashboard = false
    
    let reference: String
    let amount: String
    let currency: String
    let phoneNumber: String
    
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
                Text("Withdrawal Initiated!")
                    .h1Style()
                    .multilineTextAlignment(.center)
                
                // Message
                VStack(spacing: Spacing.sm) {
                    Text("Your withdrawal is being processed")
                        .bodyLargeStyle()
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("You will receive \(amount) \(currency) on \(phoneNumber)")
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
                    
                    Divider()
                        .background(Color.borderDefault)
                    
                    HStack {
                        Text("Phone Number")
                            .bodyRegularStyle()
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text(phoneNumber)
                            .bodyRegularStyle()
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(Spacing.md)
                .background(Color.inputBackground)
                .cornerRadius(Spacing.radiusMedium)
                
                Spacer()
                
                // Done Button
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
