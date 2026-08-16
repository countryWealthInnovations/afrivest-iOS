//
//  AdvisorsView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI

struct AdvisorsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AdvisorViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.advisors) { a in
                            NavigationLink(destination: AdvisorDetailView(advisorId: a.id)) {
                                advisorCard(a)
                            }.buttonStyle(.plain)
                        }
                        if viewModel.advisors.isEmpty && !viewModel.isLoading {
                            Text("No advisors available right now").foregroundColor(.gray).padding(.top, 40)
                        }
                    }.padding()
                }
                if viewModel.isLoading { ProgressView().tint(Color.primaryGold) }
            }
            .navigationTitle("Advisors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() }.foregroundColor(Color.primaryGold) }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: MyBookingsView()) { Text("My Bookings").foregroundColor(Color.primaryGold) }
                }
            }
            .onAppear { viewModel.loadAdvisors() }
        }
    }

    private func advisorCard(_ a: Advisor) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(a.displayName).font(.headline).foregroundColor(.white)
            if let t = a.title { Text(t).font(.subheadline).foregroundColor(.gray) }
            if let e = a.expertise { Text(e).font(.caption).foregroundColor(.gray) }
            Text("Fee: \(a.bookingFeeCurrency ?? "") \(a.bookingFee ?? "0")  •  \(a.sessionDurationMinutes ?? 30) min")
                .font(.caption).foregroundColor(Color.primaryGold).padding(.top, 4)
        }
        .padding().frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.18)).cornerRadius(12)
    }
}