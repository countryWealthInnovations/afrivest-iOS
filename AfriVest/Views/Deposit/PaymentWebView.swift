//
//  PaymentWebView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 10/10/2025.
//

import SwiftUI
import WebKit

struct PaymentWebView: View {
    let paymentUrl: String
    let transactionId: Int
    let reference: String
    let amount: String
    let currency: String
    let network: String?
    
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var navigateToStatus = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                WebView(
                    url: paymentUrl,
                    isLoading: $isLoading,
                    onComplete: {
                        // Payment completed
                        navigateToStatus = true
                    }
                )
                
                if isLoading {
                    ProgressView("Loading payment page...")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Complete Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Navigate to status screen even on cancel
                        navigateToStatus = true
                    }
                }
            }
            .fullScreenCover(isPresented: $navigateToStatus) {
                DepositProcessingView(
                    reference: reference,
                    amount: amount,
                    currency: currency
                )
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    let onComplete: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: url), webView.url == nil {
            let request = URLRequest(url: url, timeoutInterval: 30) // ← ADD TIMEOUT
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("❌ WebView failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                print("📍 WebView navigating to: \(url.absoluteString)")
                
                // Check if this is the return URL
                if url.absoluteString.contains("/api/deposits/return") ||
                   url.absoluteString.contains("action=close_webview") {
                    parent.onComplete()
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
    }
}
