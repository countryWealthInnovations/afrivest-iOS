//
//  DepositViewModel.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 10/10/2025.
//

import Foundation
import Alamofire
import Combine

@MainActor
class DepositViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var phoneNumber: String = ""
    @Published var selectedNetwork: String = "MTN"
    @Published var selectedCurrency: String = "UGX"
    @Published var phoneState: TextFieldState = .normal
    
    let mobileMoneyNetworks: [String: [String]] = [
        "UGX": ["MTN", "AIRTEL"],
        "KES": ["MPESA"],
        "NGN": ["ENAIRA"],
        "GHS": ["MTN", "TELECEL", "AIRTEL"],
        "TZS": ["AIRTEL", "TIGO", "HALOPESA"],
        "RWF": ["AIRTEL", "MTN"],
        "ZMW": ["AIRTEL", "MTN", "ZAMTEL"],
        "XAF": ["MTN", "ORANGE"],
        "XOF": ["MTN", "ORANGE", "WAVE"],
    ]
    
    var availableNetworks: [String] {
        mobileMoneyNetworks[selectedCurrency] ?? ["MTN", "AIRTEL"]
    }
    
    var availableCurrencies: [String] {
        Array(mobileMoneyNetworks.keys).sorted()
    }
    
    var minimumAmount: Double {
        switch selectedCurrency {
        case "UGX": return 5000
        case "KES": return 50
        case "NGN": return 100
        case "GHS": return 5
        case "TZS": return 10000
        case "RWF": return 1000
        case "ZMW": return 10
        case "XAF", "XOF": return 500
        case "USD", "EUR", "GBP", "CAD", "AED": return 1
        default: return 5000
        }
    }
    
    var bankMinimumAmount: Double {
        switch selectedBankCurrency {
        case "NGN": return 100
        case "GHS": return 5
        case "GBP", "EUR": return 1
        default: return 1
        }
    }
    
    var dialCode: String {
        switch selectedCurrency {
        case "UGX": return "+256"
        case "KES": return "+254"
        case "NGN": return "+234"
        case "GHS": return "+233"
        case "TZS": return "+255"
        case "RWF": return "+250"
        case "ZMW": return "+260"
        case "XAF": return "+237"
        case "XOF": return "+225"
        default: return "+256"
        }
    }
    
    // Card fields
    @Published var cardNumber: String = ""
    @Published var cvv: String = ""
    @Published var expiryMonth: String = ""
    @Published var expiryYear: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFormValid: Bool = false
    @Published var isCardFormValid: Bool = false
    
    @Published var depositResponse: DepositResponse?
    @Published var transactionStatus: TransactionStatus?
    @Published var shouldNavigateToWebView: Bool = false
    @Published var shouldNavigateToStatus: Bool = false
    @Published var showPushNotificationMessage: Bool = false
    @Published var pushNotificationReference: String = ""
    @Published var showBankTransferDetails: Bool = false
    @Published var bankTransferMessage: String = ""
    @Published var shouldNavigateToBankConfirmation: Bool = false
    @Published var bankConfirmationDetails: BankTransferDetails?
    
    // Bank tab (merged Bank Transfer + Pay With Bank)
    @Published var bankSubMethod: String = "virtual_account" // "virtual_account" | "internet_banking"
    @Published var selectedBankCurrency: String = "NGN"
    @Published var selectedBankType: String = "bank_transfer"
    @Published var selectedPayWithBankCountry: String = "NG"
    @Published var isBankFormValid: Bool = false
    @Published var bankAccountNumber: String = ""
    @Published var bankCode: String = ""
    
    func setBankSubMethod(_ method: String) {
        bankSubMethod = method
        amount = ""
        if method == "virtual_account" {
            selectedBankCurrency = "NGN"
            selectedBankType = "bank_transfer"
        } else {
            selectedPayWithBankCountry = "NG"
            applyPayWithBankCountry()
        }
        revalidateBankForm()
    }
    
    func applyPayWithBankCountry() {
        amount = ""
        switch selectedPayWithBankCountry {
        case "UK":
            selectedBankCurrency = "GBP"
            selectedBankType = "pay_with_bank_uk"
        case "EU":
            selectedBankCurrency = "EUR"
            selectedBankType = "pay_with_bank_uk"
        default:
            selectedBankCurrency = "NGN"
            selectedBankType = "pay_with_bank_ng"
        }
        revalidateBankForm()
    }
    
    func setVirtualAccountCurrency(_ currency: String) {
        amount = ""
        selectedBankCurrency = currency
        selectedBankType = "bank_transfer"
        revalidateBankForm()
    }
    
    func revalidateBankForm() {
        let value = Double(amount) ?? 0
        isBankFormValid = value >= bankMinimumAmount
    }
    
    // Fee preview
    @Published var estimatedServiceFee: Double = 0.0
    @Published var estimatedTotal: Double = 0.0
    
    private let depositService = DepositService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest3($amount, $phoneNumber, $phoneState)
            .map { [weak self] amount, phone, phoneState in
                guard let self else { return false }
                guard let amountValue = Double(amount), amountValue >= self.minimumAmount else {
                    return false
                }
                return phoneState == .success && !phone.isEmpty
            }
            .assign(to: &$isFormValid)
        
        // Card form validation
        Publishers.CombineLatest($amount, Publishers.CombineLatest4($cardNumber, $cvv, $expiryMonth, $expiryYear))
            .map { amount, cardFields in
                let (cardNumber, cvv, expiryMonth, expiryYear) = cardFields
                
                guard let amountValue = Double(amount), amountValue >= 4999 else {
                    return false
                }
                
                let cardNumberValid = cardNumber.replacingOccurrences(of: " ", with: "").count == 16
                let cvvValid = cvv.count == 3
                let expiryMonthValid = expiryMonth.count == 2 && (Int(expiryMonth) ?? 0) >= 1 && (Int(expiryMonth) ?? 0) <= 12
                let expiryYearValid = expiryYear.count == 2
                
                return cardNumberValid && cvvValid && expiryMonthValid && expiryYearValid
            }
            .assign(to: &$isCardFormValid)
        
        // Auto-detect network from phone number
        $phoneNumber
            .sink { [weak self] phone in
                self?.detectNetwork(from: phone)
                self?.validatePhoneNumber(phone)
            }
            .store(in: &cancellables)
        
        // Bank form validation — amount-based only, all bank flows are redirect or virtual-account based
        Publishers.CombineLatest($amount, $selectedBankCurrency)
            .map { [weak self] amount, _ in
                guard let self, let value = Double(amount) else { return false }
                return value >= self.bankMinimumAmount
            }
            .assign(to: &$isBankFormValid)
        
        // Estimate deposit fee as amount changes (deposits are free by default)
        $amount
            .sink { [weak self] amount in
                guard let self, let value = Double(amount), value > 0 else {
                    self?.estimatedServiceFee = 0
                    self?.estimatedTotal = 0
                    return
                }
                // Deposits are free — service fee is 0 unless admin configured otherwise
                self.estimatedServiceFee = 0
                self.estimatedTotal = value
            }
            .store(in: &cancellables)
    }
    
    private func detectNetwork(from phone: String) {
        guard selectedCurrency == "UGX" else { return }
        if phone.hasPrefix("77") || phone.hasPrefix("78") || phone.hasPrefix("76") || phone.hasPrefix("79") {
            selectedNetwork = "MTN"
        } else if phone.hasPrefix("70") || phone.hasPrefix("74") || phone.hasPrefix("75") {
            selectedNetwork = "AIRTEL"
        }
    }
    
    private func validatePhoneNumber(_ phone: String) {
        if phone.isEmpty {
            phoneState = .normal
        } else if Validators.isValidPhoneNumber(phone) {
            phoneState = .success
        } else {
            phoneState = .error
        }
    }
    
    func initiateDeposit() {
        guard isFormValid else { return }
        let formattedPhone = phoneNumber.hasPrefix("+") ? phoneNumber : "\(dialCode)\(phoneNumber)"
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await depositService.depositMobileMoney(
                    amount: Double(amount) ?? 0,
                    currency: selectedCurrency,
                    network: selectedNetwork,
                    phoneNumber: formattedPhone
                )
                
                depositResponse = response
                if response.paymentData.paymentUrl != nil {
                    shouldNavigateToWebView = true
                } else {
                    pushNotificationReference = response.reference
                    showPushNotificationMessage = true
                }
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func initiateCardDeposit() {
        guard !amount.isEmpty,
              let amountValue = Double(amount),
              amountValue >= 1000,
              !cardNumber.isEmpty,
              cardNumber.replacingOccurrences(of: " ", with: "").count == 16,
              !cvv.isEmpty,
              cvv.count == 3,
              !expiryMonth.isEmpty,
              expiryMonth.count == 2,
              !expiryYear.isEmpty,
              expiryYear.count == 2 else {
            errorMessage = "Please fill in all card details correctly"
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await depositService.depositCard(
                    amount: amountValue,
                    currency: selectedCurrency,
                    cardNumber: cardNumber.replacingOccurrences(of: " ", with: ""),
                    cvv: cvv,
                    expiryMonth: expiryMonth,
                    expiryYear: expiryYear
                )
                
                depositResponse = response
                shouldNavigateToWebView = true
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func initiateBankDeposit() {
        guard isBankFormValid else { return }
        BankTransferDetails.clear()
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let parameters: [String: Any] = [
                    "amount": Double(amount) ?? 0,
                    "currency": selectedBankCurrency,
                    "type": selectedBankType
                ]
                
                let response: BankDepositResponse = try await APIClient.shared.request(
                    "/deposits/bank",
                    method: .post,
                    parameters: parameters,
                    requiresAuth: true
                )
                
                if (selectedBankType == "pay_with_bank_ng" || selectedBankType == "pay_with_bank_uk"),
                   let redirectUrl = response.paymentData.redirectUrl ?? response.paymentData.authorizationUrl {
                    // NG/UK/EU Pay With Bank — redirect to WebView only, no stored confirmation
                    depositResponse = DepositResponse(
                        transactionId: response.transactionId,
                        amount: response.amount,
                        flutterwaveFee: nil,
                        serviceFee: nil,
                        totalFee: nil,
                        userPays: nil,
                        userReceives: nil,
                        currency: response.currency,
                        status: response.status,
                        network: nil,
                        reference: response.reference,
                        paymentData: PaymentData(
                            mode: response.paymentData.mode ?? "redirect",
                            url: redirectUrl,
                            authorizationUrl: redirectUrl,
                            redirectUrl: redirectUrl,
                            flutterwaveTransactionId: nil
                        )
                    )
                    shouldNavigateToWebView = true
                } else if let account = response.paymentData.transferAccount,
                          let bank = response.paymentData.transferBank {
                    // NGN/GHS Bank Transfer — store details and navigate to confirmation screen
                    let details = BankTransferDetails(
                        type: .bankTransfer,
                        transactionId: response.transactionId,
                        bankName: bank,
                        sortCode: nil,
                        accountNumber: account,
                        amount: response.paymentData.transferAmount ?? String(response.amount),
                        currency: response.currency,
                        reference: response.paymentData.transferNote ?? response.reference,
                        expiration: response.paymentData.accountExpiration
                    )
                    BankTransferDetails.save(details)
                    bankConfirmationDetails = details
                    shouldNavigateToBankConfirmation = true
                } else {
                    errorMessage = "Unable to process bank deposit. Please try again."
                }
                
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
