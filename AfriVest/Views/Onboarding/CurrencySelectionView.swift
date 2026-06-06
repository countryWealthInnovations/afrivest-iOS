//
//  CurrencySelectionView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 19/05/2026.
//

import SwiftUI

struct CurrencySelectionView: View {
    @StateObject private var vm = CurrencySelectionViewModel()
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(Color.primaryGold)
                        
                        Text("Set Your Currency")
                            .font(AppFont.heading2())
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Choose the currency you'll primarily use for transactions and investments.")
                            .font(AppFont.bodyRegular())
                            .foregroundColor(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Currency")
                            .font(AppFont.label())
                            .foregroundColor(Color.textSecondary)
                        currencyPicker(selection: $vm.defaultCurrency)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Secondary Currency (Optional)")
                            .font(AppFont.label())
                            .foregroundColor(Color.textSecondary)
                        currencyPicker(selection: $vm.secondaryCurrency, includeNone: true)
                    }
                    .padding(.horizontal)
                    
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(AppFont.bodySmall())
                            .foregroundColor(.errorRed)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    let isVerified = UserDefaultsManager.shared.emailVerified
                    
                    if !isVerified {
                        Text("⚠️ Please verify your email before setting your currency.")
                            .font(AppFont.bodySmall())
                            .foregroundColor(Color.warningYellow)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    PrimaryButton(title: vm.isLoading ? "Saving..." : "Continue") {
                        Task {
                            let success = await vm.saveCurrency()
                            if success { isPresented = false }
                        }
                    }
                    .disabled(vm.isLoading || !isVerified)
                    .opacity(!isVerified ? 0.5 : 1.0)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func currencyPicker(selection: Binding<String>, includeNone: Bool = false) -> some View {
        Menu {
            if includeNone {
                Button("None") { selection.wrappedValue = "" }
            }
            ForEach(CurrencySelectionViewModel.supported, id: \.code) { c in
                Button("\(c.flag) \(c.code) — \(c.name)") {
                    selection.wrappedValue = c.code
                }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue.isEmpty ? "Select currency" : selection.wrappedValue)
                    .font(AppFont.bodyLarge())
                    .foregroundColor(selection.wrappedValue.isEmpty ? Color.textSecondary : Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color.primaryGold)
            }
            .padding()
            .background(Color.backgroundDark1)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryGold.opacity(0.4), lineWidth: 1)
            )
        }
    }
}
