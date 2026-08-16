//
//  InvestmentAgreementSheet.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI

struct InvestmentAgreementSheet: View {
    let title: String
    let bodyText: String
    let onAccept: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        Text(bodyText)
                            .font(AppFont.bodyRegular())
                            .foregroundColor(Color.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(Spacing.md)
                    }

                    VStack(spacing: Spacing.sm) {
                        Button(action: { dismiss(); onAccept() }) {
                            Text("Accept and Continue")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryGold)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        Button("Cancel") { dismiss(); onCancel() }
                            .foregroundColor(Color.textSecondary)
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
