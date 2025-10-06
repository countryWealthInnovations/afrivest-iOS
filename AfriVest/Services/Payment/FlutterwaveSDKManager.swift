//
//  FlutterwaveSDKManager.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 06/10/2025.
//

import Foundation
import FlutterwaveSDK

class FlutterwaveSDKManager: NSObject, FlutterwavePayProtocol {
    
    static let shared = FlutterwaveSDKManager()
    
    private var completionHandler: ((Result<FlutterwaveSDKResult, Error>) -> Void)?
    
    struct FlutterwaveSDKResult {
        let flwRef: String
        let status: String
        let responseData: FlutterwaveDataResponse?
    }
    
    // MARK: - Initiate Payment
    
    func initiatePayment(
        from viewController: UIViewController,
        amount: String,
        currency: String,
        txRef: String,
        email: String,
        name: String,
        phoneNumber: String,
        publicKey: String,
        encryptionKey: String,
        isStaging: Bool = false,
        completion: @escaping (Result<FlutterwaveSDKResult, Error>) -> Void
    ) {
        self.completionHandler = completion
        
        let config = FlutterwaveConfig.sharedConfig()
        
        // Payment options - Enable ALL methods
        config.paymentOptionsToExclude = [] // Empty = all enabled
        
        // Transaction details
        config.currencyCode = currency
        config.email = email
        config.isStaging = isStaging
        config.phoneNumber = phoneNumber
        config.transcationRef = txRef
        
        // Customer details
        let nameParts = name.components(separatedBy: " ")
        config.firstName = nameParts.first ?? name
        config.lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
        
        // Meta data
        config.meta = [
            ["metaname": "sdk", "metavalue": "ios"],
            ["metaname": "platform", "metavalue": "mobile"]
        ]
        
        config.narration = "AfriVest Deposit"
        config.publicKey = publicKey
        config.encryptionKey = encryptionKey
        config.isPreAuth = false
        
        // Initialize controller
        let controller = FlutterwavePayViewController()
        let nav = UINavigationController(rootViewController: controller)
        controller.amount = amount
        controller.delegate = self
        
        viewController.present(nav, animated: true)
    }
    
    // MARK: - FlutterwavePayProtocol
    
    func tranasctionSuccessful(flwRef: String?, responseData: FlutterwaveDataResponse?) {
        print("✅ Transaction successful: \(flwRef ?? "No ref")")
        
        guard let ref = flwRef else {
            completionHandler?(.failure(NSError(domain: "FlutterwaveSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "No reference returned"])))
            return
        }
        
        let result = FlutterwaveSDKResult(
            flwRef: ref,
            status: "successful",
            responseData: responseData
        )
        
        completionHandler?(.success(result))
    }
    
    func tranasctionFailed(flwRef: String?, responseData: FlutterwaveDataResponse?) {
        print("❌ Transaction failed: \(flwRef ?? "No ref")")
        
        let result = FlutterwaveSDKResult(
            flwRef: flwRef ?? "",
            status: "failed",
            responseData: responseData
        )
        
        completionHandler?(.success(result)) // Still "success" because SDK returned
    }
    
    func onDismiss() {
        print("🚫 Payment cancelled by user")
        completionHandler?(.failure(NSError(domain: "FlutterwaveSDK", code: -2, userInfo: [NSLocalizedDescriptionKey: "Payment cancelled"])))
    }
}
