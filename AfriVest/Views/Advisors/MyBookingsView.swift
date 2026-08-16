//
//  MyBookingsView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI

struct MyBookingsView: View {
    @StateObject private var viewModel = AdvisorViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.bookings) { b in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(b.advisorName ?? "Advisor session").font(.headline).foregroundColor(.white)
                            Text("\(b.scheduledAt.prefix(16).replacingOccurrences(of: "T", with: " "))  •  \(b.status)")
                                .font(.caption).foregroundColor(.gray)
                            if let link = b.meetingLink, let url = URL(string: link) {
                                Link("Join meeting", destination: url).font(.subheadline).foregroundColor(Color.primaryGold).padding(.top, 4)
                            }
                        }.padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(white: 0.18)).cornerRadius(12)
                    }
                    if viewModel.bookings.isEmpty && !viewModel.isLoading {
                        Text("No bookings yet").foregroundColor(.gray).padding(.top, 40)
                    }
                }.padding()
            }
        }
        .navigationTitle("My Bookings").navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadBookings() }
    }
}