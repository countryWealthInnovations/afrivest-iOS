//
//  FloatingActionButton.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 04/10/2025.
//

import SwiftUI

struct FloatingActionButton: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            if isExpanded {
                // Send Money Button
                ActionButton(
                    icon: "paperplane.fill",
                    title: "Send Money",
                    action: {
                        // TODO: Navigate to send money
                        print("Send Money tapped")
                    }
                )
                
                // Receive Money Button
                ActionButton(
                    icon: "qrcode",
                    title: "Receive Money",
                    action: {
                        // TODO: Navigate to receive money
                        print("Receive Money tapped")
                    }
                )
            }
            
            // Main FAB Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 56, height: 56)
                    .background(Color.primaryGold)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(AppFont.button())
            }
            .foregroundColor(.black)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.primaryGold)
            .cornerRadius(Spacing.radiusLarge)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}
