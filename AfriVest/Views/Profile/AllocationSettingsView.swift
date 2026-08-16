//
//  AllocationSettingsView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import SwiftUI
import Alamofire
import Combine

struct AllocationPayload: Codable, Sendable {
    let allocation: [String: Int]
    let allowed_targets: [String]
    
    enum CodingKeys: String, CodingKey { case allocation, allowed_targets }
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        allocation = (try? c.decode([String: Int].self, forKey: .allocation)) ?? [:]
        allowed_targets = (try? c.decode([String].self, forKey: .allowed_targets)) ?? []
    }
}

@MainActor
final class AllocationSettingsViewModel: ObservableObject {
    @Published var targets: [String] = []
    @Published var values: [String: Int] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var saved = false
    
    private let apiClient = APIClient.shared
    
    var total: Int { values.values.reduce(0, +) }
    var canSave: Bool { total == 100 && !isLoading }
    
    func load() {
        isLoading = true
        Task {
            do {
                let payload: AllocationPayload = try await apiClient.request(
                    "/profile/allocation", method: .get, parameters: nil, requiresAuth: true)
                var v: [String: Int] = [:]
                for t in payload.allowed_targets { v[t] = payload.allocation[t] ?? 0 }
                self.targets = payload.allowed_targets
                self.values = v
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func adjust(_ target: String, _ delta: Int) {
        let next = min(100, max(0, (values[target] ?? 0) + delta))
        values[target] = next
    }
    
    func save() {
        guard total == 100 else { errorMessage = "Allocation must total 100%"; return }
        isLoading = true
        Task {
            do {
                let _: EmptyDataResponse = try await apiClient.request(
                    "/profile/allocation", method: .put,
                    parameters: ["allocation": values], requiresAuth: true)
                self.saved = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}

struct AllocationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AllocationSettingsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Choose how each deposit is split. Must total 100%.")
                                .font(AppFont.bodySmall())
                                .foregroundColor(Color.textSecondary)
                                .padding(.top, Spacing.sm)
                            
                            ForEach(viewModel.targets, id: \.self) { target in
                                row(target)
                            }
                            
                            HStack {
                                Spacer()
                                Text("Total: \(viewModel.total)%")
                                    .font(AppFont.bodyLarge())
                                    .foregroundColor(viewModel.total == 100 ? .green : Color.primaryGold)
                            }
                            .padding(.top, Spacing.sm)
                        }
                        .padding(Spacing.screenHorizontal)
                    }
                    
                    Button(action: { viewModel.save() }) {
                        Text("Save").bold().frame(maxWidth: .infinity).padding()
                            .background(viewModel.canSave ? Color.primaryGold : Color.gray.opacity(0.4))
                            .foregroundColor(.black).cornerRadius(10)
                    }
                    .disabled(!viewModel.canSave)
                    .padding(Spacing.screenHorizontal)
                    .padding(.bottom, Spacing.md)
                }
                
                if viewModel.isLoading { ProgressView().tint(Color.primaryGold) }
            }
            .navigationTitle("Deposit Allocation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(Color.primaryGold)
                }
            }
            .onAppear { viewModel.load() }
            .onChange(of: viewModel.saved) { if $0 { dismiss() } }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "") }
        }
    }
    
    private func row(_ target: String) -> some View {
        HStack {
            Text(label(target))
                .font(AppFont.bodyRegular())
                .foregroundColor(Color.textPrimary)
            Spacer()
            Button(action: { viewModel.adjust(target, -5) }) {
                Image(systemName: "minus.circle.fill").foregroundColor(Color.primaryGold).font(.system(size: 26))
            }
            Text("\(viewModel.values[target] ?? 0)%")
                .font(AppFont.bodyLarge())
                .foregroundColor(Color.primaryGold)
                .frame(width: 56)
            Button(action: { viewModel.adjust(target, +5) }) {
                Image(systemName: "plus.circle.fill").foregroundColor(Color.primaryGold).font(.system(size: 26))
            }
        }
        .padding(.vertical, Spacing.sm)
    }
    
    private func label(_ target: String) -> String {
        switch target {
        case "wallet": return "Wallet (spendable)"
        case "savings": return "Savings"
        case "investment": return "Investment"
        case "p2p": return "Send to family (P2P)"
        default: return target.capitalized
        }
    }
}
