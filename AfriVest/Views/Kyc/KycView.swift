//
//  KycView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//

import SwiftUI
import Combine
import DiditSDK

@MainActor
final class KycViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle, creatingSession, verifying, approved, declined, pending, cancelled
        case error(String)
    }
    
    @Published var phase: Phase = .idle
    private let service = KycService.shared
    
    func startVerification() {
        guard phase != .creatingSession, phase != .verifying else { return }
        phase = .creatingSession
        Task {
            do {
                let session = try await service.createSession()
                guard let token = session.session_token, !token.isEmpty else {
                    phase = .error("Verification session missing token")
                    return
                }
                phase = .verifying
                DiditSdk.shared.startVerification(token: token)
            } catch {
                phase = .error(error.localizedDescription)
            }
        }
    }
    
    func handle(result: VerificationResult) {
        switch result {
        case .completed(let session):
            switch session.status {
            case .approved: phase = .approved; pollStatus()
            case .declined: phase = .declined
            case .pending: phase = .pending; pollStatus()
            @unknown default: phase = .error("Unknown verification status")
            }
        case .cancelled:
            phase = .cancelled
        case .failed(let error, _):
            phase = .error(error.localizedDescription)
        @unknown default:
            phase = .error("Verification failed")
        }
    }
    
    func cancelInFlight() {
        guard phase == .verifying else { return }
        DiditSdk.shared.dismiss()
    }
    
    private func pollStatus() {
        Task {
            for _ in 0..<6 {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                if let s = try? await service.getStatus() {
                    if s.verified == true {
                        UserDefaultsManager.shared.kycVerified = true
                        phase = .approved
                        return
                    }
                    if s.status == "rejected" { phase = .declined; return }
                    if s.status == "in_review" || s.status == "review" { phase = .pending }
                }
            }
        }
    }
}

struct KycView: View {
    @StateObject private var viewModel = KycViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                statusIcon
                    .font(.system(size: 56))
                    .foregroundStyle(statusColor)
                
                Text(statusTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let subtitle = statusSubtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                if showsSpinner {
                    ProgressView().tint(Color.primaryGold)
                }
                
                if showsRetry {
                    Button(action: { viewModel.startVerification() }) {
                        Text("Try Again").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryGold)
                    .padding(.horizontal, 40)
                }
                
                if showsDone {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color.primaryGold)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .overlay(alignment: .topLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.primaryGold)
                    .padding(12)
            }
            .padding(.top, 8)
            .padding(.leading, 8)
        }
        .diditVerification { result in
            viewModel.handle(result: result)
        }
        .onAppear {
            if viewModel.phase == .idle { viewModel.startVerification() }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background { viewModel.cancelInFlight() }
        }
    }
    
    private var showsSpinner: Bool {
        viewModel.phase == .idle || viewModel.phase == .creatingSession || viewModel.phase == .verifying
    }
    private var showsRetry: Bool {
        if case .error = viewModel.phase { return true }
        return viewModel.phase == .declined || viewModel.phase == .cancelled
    }
    private var showsDone: Bool {
        viewModel.phase == .approved || viewModel.phase == .pending
    }
    
    private var statusIcon: Image {
        switch viewModel.phase {
        case .approved: return Image(systemName: "checkmark.seal.fill")
        case .declined: return Image(systemName: "xmark.seal.fill")
        case .pending: return Image(systemName: "clock.fill")
        case .error: return Image(systemName: "exclamationmark.triangle.fill")
        case .cancelled: return Image(systemName: "person.crop.circle.badge.questionmark")
        default: return Image(systemName: "person.crop.circle.badge.checkmark")
        }
    }
    
    private var statusColor: Color {
        switch viewModel.phase {
        case .approved: return .green
        case .declined, .error: return .red
        case .pending: return .orange
        default: return Color.primaryGold
        }
    }
    
    private var statusTitle: String {
        switch viewModel.phase {
        case .idle, .creatingSession: return "Starting verification"
        case .verifying: return "Verification in progress"
        case .approved: return "Identity Verified"
        case .declined: return "Verification Declined"
        case .pending: return "Under Review"
        case .cancelled: return "Verification Cancelled"
        case .error: return "Something Went Wrong"
        }
    }
    
    private var statusSubtitle: String? {
        switch viewModel.phase {
        case .declined: return "We couldn't verify your identity. Try again or contact support."
        case .pending: return "Our compliance team is reviewing your submission. This can take a few minutes."
        case .cancelled: return "You closed the verification flow before finishing."
        case .error(let message): return message
        default: return nil
        }
    }
}
