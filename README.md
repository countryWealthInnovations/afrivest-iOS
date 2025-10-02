# AfriVest iOS App

Investment-First Remittance Platform for the Ugandan Diaspora

## Overview

AfriVest is a fintech remittance platform that transforms money transfers into investment opportunities. The platform integrates real estate, insurance, gold, and crypto investments alongside traditional remittance services, targeting Ugandan diaspora communities in the US, UK, UAE, EU, and Canada.

**Backend API:** `https://afrivest.countrywealth.ug/api/`  
**Status:** Foundation Complete - Ready for UI Development  
**Date:** January 2025

## Features

### Core Functionality
- Multi-currency wallet management (UGX, USD, EUR, GBP)
- Secure user authentication with OTP verification
- Real-time transaction tracking and history
- Face ID / Touch ID authentication
- Push notifications for transaction updates
- Offline data caching with Core Data (optional)

### Financial Services
- **Deposits:** Card payment, Mobile Money (MTN, Airtel), Bank transfer
- **Withdrawals:** Bank account, Mobile Money
- **P2P Transfers:** Send money to other AfriVest users
- **Bill Payments:** Utilities, airtime/data, TV subscriptions

### Investment Opportunities
- Real Estate marketplace
- Insurance products
- Gold trading
- Cryptocurrency trading

### Security & Compliance
- KYC verification system
- Keychain secure storage for tokens
- Biometric authentication
- Certificate pinning for API security

## Tech Stack

### Core
- **Platform:** iOS 15.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** MVVM with Clean Architecture
- **Xcode:** 15.0+

### Dependencies (Swift Package Manager)

**Networking:**
- Alamofire 5.9.0 - HTTP networking library

**Security:**
- KeychainSwift 20.0.0 - Keychain wrapper for secure storage

**Firebase:**
- Firebase iOS SDK 10.20.0
  - Firebase Messaging - Push notifications
  - Firebase Analytics - User analytics
  - Firebase Crashlytics - Crash reporting

**Image Loading:**
- Kingfisher 7.10.0 - Async image downloading and caching

**Animations:**
- Lottie 4.4.0 - JSON-based animations

## Project Structure

```
AfriVest/
├── AfriVest/
│   ├── App/
│   │   ├── AfriVestApp.swift              # SwiftUI App entry point
│   │   └── AppDelegate.swift              # App lifecycle delegate
│   │
│   ├── Core/
│   │   ├── Network/
│   │   │   ├── APIClient.swift            # Alamofire networking layer
│   │   │   ├── APIEndpoint.swift          # API endpoint definitions
│   │   │   ├── APIError.swift             # Error handling
│   │   │   └── NetworkMonitor.swift       # Network reachability
│   │   │
│   │   ├── Storage/
│   │   │   ├── KeychainManager.swift      # Secure token storage
│   │   │   ├── UserDefaultsManager.swift  # App settings
│   │   │   └── SecureStorage.swift        # Generic secure storage
│   │   │
│   │   ├── Utils/
│   │   │   ├── Extensions/                # Swift extensions
│   │   │   ├── Validators/                # Input validation
│   │   │   └── Formatters/                # Data formatters
│   │   │
│   │   └── Constants/
│   │       ├── APIConstants.swift         # API configuration
│   │       └── AppConstants.swift         # App-wide constants
│   │
│   ├── Models/
│   │   ├── User.swift                     # User data model
│   │   ├── Wallet.swift                   # Wallet data model
│   │   ├── Transaction.swift              # Transaction data model
│   │   └── APIResponse.swift              # Generic API response
│   │
│   ├── ViewModels/
│   │   ├── Auth/                          # Authentication ViewModels
│   │   ├── Wallet/                        # Wallet ViewModels
│   │   ├── Transaction/                   # Transaction ViewModels
│   │   └── Profile/                       # Profile ViewModels
│   │
│   ├── Views/
│   │   ├── Authentication/
│   │   │   ├── LoginView.swift            # Login screen
│   │   │   ├── RegisterView.swift         # Registration screen
│   │   │   ├── OTPView.swift              # OTP verification
│   │   │   └── ForgotPasswordView.swift   # Password recovery
│   │   │
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift        # Home dashboard
│   │   │   └── Components/                # Reusable components
│   │   │
│   │   ├── Wallet/
│   │   │   ├── WalletListView.swift       # Wallet list
│   │   │   └── WalletDetailView.swift     # Single wallet detail
│   │   │
│   │   ├── Transactions/
│   │   │   ├── TransactionListView.swift  # Transaction history
│   │   │   └── TransactionDetailView.swift # Transaction detail
│   │   │
│   │   ├── Transfers/
│   │   │   ├── DepositView.swift          # Deposit money
│   │   │   ├── WithdrawView.swift         # Withdraw money
│   │   │   └── P2PTransferView.swift      # P2P transfer
│   │   │
│   │   └── Profile/
│   │       └── ProfileView.swift          # User profile
│   │
│   ├── Components/
│   │   ├── Buttons/                       # Reusable buttons
│   │   ├── TextFields/                    # Custom text fields
│   │   ├── Cards/                         # Card components
│   │   └── LoadingViews/                  # Loading indicators
│   │
│   └── Resources/
│       ├── Assets.xcassets                # Image assets
│       ├── Colors.xcassets                # Color assets
│       ├── GoogleService-Info.plist       # Firebase config
│       └── Info.plist                     # App configuration
│
├── AfriVestTests/                         # Unit tests
└── AfriVestUITests/                       # UI tests
```

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- iOS 15.0+ deployment target
- Swift 5.9+
- CocoaPods or Swift Package Manager
- Apple Developer Account (for device testing)

## Setup Instructions

### 1. Clone Repository

```bash
git clone https://github.com/countryWealthInnovations/afrivest-iOS.git
cd afrivest-iOS
```

### 2. Open in Xcode

```bash
# Open the Xcode project
open AfriVest.xcodeproj
```

Or:
1. Launch Xcode
2. Select "Open a project or file"
3. Navigate to `AfriVest.xcodeproj`

### 3. Configure Signing & Capabilities

1. Select the project in the navigator
2. Select the "AfriVest" target
3. Go to "Signing & Capabilities" tab
4. Select your Team
5. Update Bundle Identifier if needed: `com.countrywealth.afrivest`

### 4. Add Swift Package Dependencies

Xcode should automatically resolve packages. If not:

1. Go to **File → Add Packages...**
2. Add the following packages:

```
https://github.com/Alamofire/Alamofire.git (5.9.0)
https://github.com/evgenyneu/keychain-swift.git (20.0.0)
https://github.com/firebase/firebase-ios-sdk.git (10.20.0)
https://github.com/onevcat/Kingfisher.git (7.10.0)
https://github.com/airbnb/lottie-ios.git (4.4.0)
```

### 5. Firebase Setup

1. Download `GoogleService-Info.plist` from Firebase Console
2. Drag it into the Xcode project (ensure "Copy items if needed" is checked)
3. Add to the "AfriVest" target
4. Verify Bundle ID matches: `com.countrywealth.afrivest`

### 6. Build & Run

```bash
# Build the project
Command + B

# Run on simulator
Command + R
```

Or select a device/simulator from the toolbar and click the Play button.

## API Integration

### Authentication Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/me` - Get current user
- `POST /auth/verify-otp` - Verify OTP
- `POST /auth/resend-otp` - Resend OTP
- `POST /auth/forgot-password` - Password recovery
- `POST /auth/reset-password` - Reset password

### Wallet Endpoints
- `GET /wallets` - Get all user wallets
- `GET /wallets/{currency}` - Get specific wallet
- `GET /wallets/{currency}/transactions` - Wallet transactions

### Transaction Endpoints
- `POST /deposits/card` - Card deposit
- `POST /deposits/mobile-money` - Mobile money deposit
- `POST /deposits/bank-transfer` - Bank transfer deposit
- `POST /withdrawals/bank` - Bank withdrawal
- `POST /withdrawals/mobile-money` - Mobile money withdrawal
- `POST /transfers/p2p` - P2P transfer
- `POST /transfers/insurance` - Insurance purchase
- `POST /transfers/investment` - Investment
- `POST /transfers/bill-payment` - Bill payment
- `POST /transfers/gold` - Gold purchase
- `POST /transfers/crypto` - Crypto purchase
- `GET /transactions` - Get all transactions
- `GET /transactions/{id}` - Get transaction detail

### Other Endpoints
- `GET /forex/rates` - Exchange rates
- `GET /forex/convert` - Currency conversion
- `GET /dashboard` - Dashboard data
- `GET /profile` - User profile
- `PUT /profile` - Update profile
- `POST /profile/avatar` - Upload avatar

## Design System

### Brand Colors

```swift
// Primary Gold
Color(hex: "#EFBF04")

// Dark Backgrounds
Color(hex: "#2F2F2F")
Color(hex: "#333231")

// Button Gradient: #FFEAAF to #C58D30
LinearGradient(
    colors: [Color(hex: "#FFEAAF"), Color(hex: "#C58D30")],
    startPoint: .leading,
    endPoint: .trailing
)
```

### Typography
- Primary Font: San Francisco (System)
- Financial data emphasis on readability
- Clear hierarchy for amounts and labels

### UI Components
- Gradient buttons with gold theme
- Wallet cards showing balances
- Transaction list items with icons
- Investment opportunity cards
- Currency picker sheets
- Custom amount input fields

## Testing

### Unit Tests
```bash
# Run unit tests
Command + U

# Or via command line
xcodebuild test -scheme AfriVest -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests
```bash
# Run UI tests
xcodebuild test -scheme AfriVest -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AfriVestUITests
```

## Security Considerations

- All API tokens stored in Keychain
- Face ID / Touch ID for sensitive operations
- Certificate pinning for API communication
- Input validation on all user inputs
- App Transport Security (ATS) enabled
- Biometric authentication for transactions

## Build Configuration

### Debug
- Development environment
- Detailed logging enabled
- Network request/response logging
- Debug menu available

### Release
- Production environment
- Optimized builds
- Minimal logging
- Code signing for App Store

## Deployment

### TestFlight (Beta)
```bash
# Archive the app
Product → Archive

# Upload to App Store Connect
Window → Organizer → Distribute App → TestFlight
```

### App Store
1. Archive the app (Command + Shift + B)
2. Upload to App Store Connect
3. Complete App Store listing
4. Submit for review

## Development Workflow

1. Create feature branch from `main`
2. Implement feature following MVVM pattern
3. Write unit tests for business logic
4. Test on simulator and physical device
5. Create pull request with description
6. Code review and merge

## Common Issues & Solutions

### Issue: Package Dependencies Not Resolving
**Solution:**
```bash
# Reset package cache
File → Packages → Reset Package Caches
```

### Issue: Signing Error
**Solution:**
1. Check Team selection in Signing & Capabilities
2. Ensure Bundle ID is unique
3. Update provisioning profiles

### Issue: Firebase Not Working
**Solution:**
1. Verify `GoogleService-Info.plist` is in project
2. Check Bundle ID matches Firebase project
3. Clean build folder (Shift + Command + K)

### Issue: Simulator Not Launching
**Solution:**
```bash
# Reset simulators
xcrun simctl shutdown all
xcrun simctl erase all
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style Guidelines
- Follow Swift API Design Guidelines
- Use SwiftLint for code style consistency
- Write meaningful commit messages
- Document complex logic with comments
- Keep view files under 300 lines

## Version History

### Version 1.0.0 (In Development)
- Initial release
- Multi-currency wallet support
- Investment opportunities integration
- Biometric authentication
- Push notifications

## License

This project is proprietary and confidential. Unauthorized access, copying, or distribution is prohibited.

## Team

**Country Wealth Innovations**  
Building financial inclusion solutions for Africa

## Support

For technical support or bug reports:
- Email: support@countrywealth.ug
- Website: https://afrivest.countrywealth.ug

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Alamofire Documentation](https://github.com/Alamofire/Alamofire)
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)

---

**Current Status:** Foundation complete - Ready for UI implementation  
**Next Phase:** SwiftUI screen development following the structure outlined above