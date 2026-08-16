//
//  MyQrView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

struct MyQrView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var qrImage: UIImage?
    @State private var name: String = ""
    @State private var error: String?

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 24) {
                    Text(name)
                        .font(AppFont.heading3())
                        .foregroundColor(Color.textPrimary)

                    if let qrImage = qrImage {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                    } else {
                        ProgressView().tint(Color.primaryGold)
                    }

                    Text("Show this code to receive money")
                        .font(AppFont.bodySmall())
                        .foregroundColor(Color.textSecondary)
                }
                .padding()
            }
            .navigationTitle("My QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(Color.primaryGold)
                }
            }
            .onAppear(perform: load)
            .alert("Error", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("OK") { error = nil }
            } message: { Text(error ?? "") }
        }
    }

    private func load() {
        name = UserDefaultsManager.shared.getCachedProfile()?.name ?? ""
        Task {
            do {
                let qr = try await QrService.shared.getMyQr()
                if let n = qr.name, !n.isEmpty { name = n }
                qrImage = generate(qr.uuid)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    private func generate(_ string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}