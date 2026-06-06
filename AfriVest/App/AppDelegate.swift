//
//  AppDelegate.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 01/10/2025.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import FirebaseCrashlytics
import Alamofire

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Crashlytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Refresh forex rates on app launch
        refreshForexRates()
        
        // Listen for token expiry anywhere in the app
        NotificationCenter.default.addObserver(
            forName: AppConstants.Notifications.tokenExpired,
            object: nil,
            queue: .main
        ) { _ in
            KeychainManager.shared.deleteToken()
            UserDefaultsManager.shared.clearAll()
            // Small delay to ensure views are ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("AfriVestForceLogout"),
                    object: nil
                )
            }
        }
        
        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                print("Permission granted: \(granted)")
            }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "nil")")
        
        if let token = fcmToken {
            // Save token
            UserDefaultsManager.shared.deviceToken = token
            
            // Log to Crashlytics
            Crashlytics.crashlytics().setCustomValue(token, forKey: "fcm_token")
            
            // TODO: Send to server if user is logged in
            if KeychainManager.shared.getToken() != nil {
                // Call API to update device token on server
            }
        }
    }
    
    // MARK: - Forex Rate Refresh
    private func refreshForexRates() {
        guard KeychainManager.shared.getToken() != nil else { return }
        Task {
            do {
                struct ForexRateItem: Codable, Sendable {
                    let from: String
                    let to: String
                    let rate: String
                }
                let items: [ForexRateItem] = try await APIClient.shared.request(
                    "/forex/rates",
                    method: .get,
                    requiresAuth: true
                )
                var newRates: [String: Double] = [:]
                for item in items where item.from == "UGX" {
                    newRates[item.to] = Double(item.rate) ?? 0
                }
                let stored = UserDefaultsManager.shared.object(forKey: "forex_rates") as? [String: Double] ?? [:]
                if NSDictionary(dictionary: newRates) != NSDictionary(dictionary: stored) {
                    UserDefaultsManager.shared.set(newRates, forKey: "forex_rates")
                    print("✅ Forex rates updated")
                } else {
                    print("ℹ️ Forex rates unchanged")
                }
            } catch {
                print("⚠️ Forex rate refresh failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Handle token refresh
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Handle remote notifications
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received remote notification: \(userInfo)")
        completionHandler(.newData)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Notification received in foreground: \(userInfo)")
        completionHandler([[.banner, .sound]])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped: \(userInfo)")
        
        // Extract transaction data from notification
        if let transactionIdString = userInfo["transaction_id"] as? String,
           let transactionId = Int(transactionIdString) {
            
            // Post notification to navigate to transaction detail
            NotificationCenter.default.post(
                name: NSNotification.Name("NavigateToTransaction"),
                object: nil,
                userInfo: ["transaction_id": transactionId]
            )
        }
        
        completionHandler()
    }
}
