//
//  ScanQrView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 30/07/2026.
//


import SwiftUI
import AVFoundation

struct ScanQrView: View {
    @Environment(\.dismiss) private var dismiss
    var onScanned: (String) -> Void
    @State private var permissionDenied = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                if permissionDenied {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill").font(.system(size: 44)).foregroundColor(Color.primaryGold)
                        Text("Camera access is needed to scan QR codes.")
                            .foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 32)
                    }
                } else {
                    QrScannerRepresentable { code in
                        if let uuid = extractUuid(code) {
                            onScanned(uuid)
                            dismiss()
                        }
                    } onDenied: {
                        permissionDenied = true
                    }
                    .ignoresSafeArea()

                    VStack {
                        Spacer()
                        Text("Point at an AfriVest QR code")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.bottom, 48)
                    }
                }
            }
            .navigationTitle("Scan QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(Color.primaryGold)
                }
            }
        }
    }

    private func extractUuid(_ text: String) -> String? {
        let pattern = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }
}

struct QrScannerRepresentable: UIViewControllerRepresentable {
    let onFound: (String) -> Void
    let onDenied: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onFound: onFound) }

    func makeUIViewController(context: Context) -> ScannerVC {
        let vc = ScannerVC()
        vc.onFound = { code in context.coordinator.handle(code) }
        vc.onDenied = onDenied
        return vc
    }
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}

    final class Coordinator {
        let onFound: (String) -> Void
        private var done = false
        init(onFound: @escaping (String) -> Void) { self.onFound = onFound }
        func handle(_ code: String) {
            guard !done else { return }
            done = true
            onFound(code)
        }
    }
}

final class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onFound: ((String) -> Void)?
    var onDenied: (() -> Void)?
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted { self?.configure() } else { self?.onDenied?() }
            }
        }
    }

    private func configure() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.frame = view.layer.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning { session.stopRunning() }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput objects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let obj = objects.first as? AVMetadataMachineReadableCodeObject,
              let value = obj.stringValue else { return }
        onFound?(value)
    }
}