//
//  AdvisorDetailView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI

struct AdvisorDetailView: View {
    let advisorId: Int
    @StateObject private var viewModel = AdvisorViewModel()
    @State private var selected: AdvisorSlot?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                if let a = viewModel.detail {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(a.displayName).font(.title2).bold().foregroundColor(.white)
                        if let t = a.title { Text(t).foregroundColor(.gray) }
                        if let bio = a.bio { Text(bio).font(.subheadline).foregroundColor(Color(white: 0.85)) }
                        Text("Fee: \(a.bookingFeeCurrency ?? "") \(a.bookingFee ?? "0") • \(a.sessionDurationMinutes ?? 30) min")
                            .foregroundColor(Color.primaryGold).padding(.top, 4)

                        Text("Available slots").font(.headline).foregroundColor(.white).padding(.top, 12)
                        let grouped = Dictionary(grouping: a.slots ?? [], by: { $0.date })
                        if grouped.isEmpty {
                            Text("No open slots in the next two weeks").font(.caption).foregroundColor(.gray)
                        }
                        ForEach(grouped.keys.sorted(), id: \.self) { date in
                            Text(date).font(.caption).foregroundColor(.gray).padding(.top, 8)
                            let slots = grouped[date] ?? []
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(slots) { slot in
                                    Button(slot.start) { selected = slot }
                                        .font(.caption)
                                        .padding(.vertical, 8).frame(maxWidth: .infinity)
                                        .background(selected?.datetime == slot.datetime ? Color.primaryGold : Color(white: 0.18))
                                        .foregroundColor(selected?.datetime == slot.datetime ? .black : Color.primaryGold)
                                        .cornerRadius(8)
                                }
                            }
                        }

                        Button(action: { if let s = selected { viewModel.book(id: advisorId, slot: s, notes: nil) } }) {
                            Text(selected == nil ? "Select a slot" : "Book Session").bold().frame(maxWidth: .infinity).padding()
                                .background(selected == nil ? Color.gray.opacity(0.4) : Color.primaryGold)
                                .foregroundColor(.black).cornerRadius(10)
                        }
                        .disabled(selected == nil).padding(.top, 16)
                    }.padding()
                } else if viewModel.isLoading {
                    ProgressView().tint(Color.primaryGold).padding(.top, 60)
                }
            }
        }
        .navigationTitle("Advisor").navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadDetail(id: advisorId) }
        .alert("Booking confirmed", isPresented: Binding(get: { viewModel.justBooked != nil }, set: { if !$0 { viewModel.justBooked = nil } })) {
            Button("OK") { viewModel.justBooked = nil; dismiss() }
        } message: {
            Text("Your session is confirmed.\n\(viewModel.justBooked?.meetingLink ?? "")")
        }
        .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
    }
}