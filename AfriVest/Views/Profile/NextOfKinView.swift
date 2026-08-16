//
//  NextOfKinView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 15/08/2026.
//

import SwiftUI

struct NextOfKinView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var relationship = "spouse"
    @State private var countryCode = "+256"
    @State private var phone = ""
    @State private var email = ""
    private let countryCodes: [(code: String, label: String)] = [
        ("+93", "🇦🇫 +93"),     // Afghanistan
        ("+355", "🇦🇱 +355"),   // Albania
        ("+213", "🇩🇿 +213"),   // Algeria
        ("+1684", "🇦🇸 +1684"), // American Samoa
        ("+376", "🇦🇩 +376"),   // Andorra
        ("+244", "🇦🇴 +244"),   // Angola
        ("+1264", "🇦🇮 +1264"), // Anguilla
        ("+1268", "🇦🇬 +1268"), // Antigua and Barbuda
        ("+54", "🇦🇷 +54"),     // Argentina
        ("+374", "🇦🇲 +374"),   // Armenia
        ("+297", "🇦🇼 +297"),   // Aruba
        ("+61", "🇦🇺 +61"),     // Australia
        ("+43", "🇦🇹 +43"),     // Austria
        ("+994", "🇦🇿 +994"),   // Azerbaijan
        ("+1242", "🇧🇸 +1242"), // Bahamas
        ("+973", "🇧🇭 +973"),   // Bahrain
        ("+880", "🇧🇩 +880"),   // Bangladesh
        ("+1246", "🇧🇧 +1246"), // Barbados
        ("+375", "🇧🇾 +375"),   // Belarus
        ("+32", "🇧🇪 +32"),     // Belgium
        ("+501", "🇧🇿 +501"),   // Belize
        ("+229", "🇧🇯 +229"),   // Benin
        ("+1441", "🇧🇲 +1441"), // Bermuda
        ("+975", "🇧🇹 +975"),   // Bhutan
        ("+591", "🇧🇴 +591"),   // Bolivia
        ("+387", "🇧🇦 +387"),   // Bosnia and Herzegovina
        ("+267", "🇧🇼 +267"),   // Botswana
        ("+55", "🇧🇷 +55"),     // Brazil
        ("+246", "🇮🇴 +246"),   // British Indian Ocean Territory
        ("+1284", "🇻🇬 +1284"), // British Virgin Islands
        ("+673", "🇧🇳 +673"),   // Brunei
        ("+359", "🇧🇬 +359"),   // Bulgaria
        ("+226", "🇧🇫 +226"),   // Burkina Faso
        ("+257", "🇧🇮 +257"),   // Burundi
        ("+855", "🇰🇭 +855"),   // Cambodia
        ("+237", "🇨🇲 +237"),   // Cameroon
        ("+1", "🇨🇦 +1"),       // Canada
        ("+238", "🇨🇻 +238"),   // Cape Verde
        ("+1345", "🇰🇾 +1345"), // Cayman Islands
        ("+236", "🇨🇫 +236"),   // Central African Republic
        ("+235", "🇹🇩 +235"),   // Chad
        ("+56", "🇨🇱 +56"),     // Chile
        ("+86", "🇨🇳 +86"),     // China
        ("+57", "🇨🇴 +57"),     // Colombia
        ("+269", "🇰🇲 +269"),   // Comoros
        ("+243", "🇨🇩 +243"),   // Congo (DRC)
        ("+242", "🇨🇬 +242"),   // Congo (Republic)
        ("+682", "🇨🇰 +682"),   // Cook Islands
        ("+506", "🇨🇷 +506"),   // Costa Rica
        ("+225", "🇨🇮 +225"),   // Côte d'Ivoire
        ("+385", "🇭🇷 +385"),   // Croatia
        ("+53", "🇨🇺 +53"),     // Cuba
        ("+599", "🇨🇼 +599"),   // Curaçao
        ("+357", "🇨🇾 +357"),   // Cyprus
        ("+420", "🇨🇿 +420"),   // Czech Republic
        ("+45", "🇩🇰 +45"),     // Denmark
        ("+253", "🇩🇯 +253"),   // Djibouti
        ("+1767", "🇩🇲 +1767"), // Dominica
        ("+1809", "🇩🇴 +1809"), // Dominican Republic
        ("+593", "🇪🇨 +593"),   // Ecuador
        ("+20", "🇪🇬 +20"),     // Egypt
        ("+503", "🇸🇻 +503"),   // El Salvador
        ("+240", "🇬🇶 +240"),   // Equatorial Guinea
        ("+291", "🇪🇷 +291"),   // Eritrea
        ("+372", "🇪🇪 +372"),   // Estonia
        ("+268", "🇸🇿 +268"),   // Eswatini
        ("+251", "🇪🇹 +251"),   // Ethiopia
        ("+679", "🇫🇯 +679"),   // Fiji
        ("+358", "🇫🇮 +358"),   // Finland
        ("+33", "🇫🇷 +33"),     // France
        ("+594", "🇬🇫 +594"),   // French Guiana
        ("+689", "🇵🇫 +689"),   // French Polynesia
        ("+241", "🇬🇦 +241"),   // Gabon
        ("+220", "🇬🇲 +220"),   // Gambia
        ("+995", "🇬🇪 +995"),   // Georgia
        ("+49", "🇩🇪 +49"),     // Germany
        ("+233", "🇬🇭 +233"),   // Ghana
        ("+350", "🇬🇮 +350"),   // Gibraltar
        ("+30", "🇬🇷 +30"),     // Greece
        ("+299", "🇬🇱 +299"),   // Greenland
        ("+1473", "🇬🇩 +1473"), // Grenada
        ("+590", "🇬🇵 +590"),   // Guadeloupe
        ("+1671", "🇬🇺 +1671"), // Guam
        ("+502", "🇬🇹 +502"),   // Guatemala
        ("+224", "🇬🇳 +224"),   // Guinea
        ("+245", "🇬🇼 +245"),   // Guinea-Bissau
        ("+592", "🇬🇾 +592"),   // Guyana
        ("+509", "🇭🇹 +509"),   // Haiti
        ("+504", "🇭🇳 +504"),   // Honduras
        ("+852", "🇭🇰 +852"),   // Hong Kong
        ("+36", "🇭🇺 +36"),     // Hungary
        ("+354", "🇮🇸 +354"),   // Iceland
        ("+91", "🇮🇳 +91"),     // India
        ("+62", "🇮🇩 +62"),     // Indonesia
        ("+98", "🇮🇷 +98"),     // Iran
        ("+964", "🇮🇶 +964"),   // Iraq
        ("+353", "🇮🇪 +353"),   // Ireland
        ("+972", "🇮🇱 +972"),   // Israel
        ("+39", "🇮🇹 +39"),     // Italy
        ("+1876", "🇯🇲 +1876"), // Jamaica
        ("+81", "🇯🇵 +81"),     // Japan
        ("+962", "🇯🇴 +962"),   // Jordan
        ("+7", "🇰🇿 +7"),       // Kazakhstan
        ("+254", "🇰🇪 +254"),   // Kenya
        ("+686", "🇰🇮 +686"),   // Kiribati
        ("+383", "🇽🇰 +383"),   // Kosovo
        ("+965", "🇰🇼 +965"),   // Kuwait
        ("+996", "🇰🇬 +996"),   // Kyrgyzstan
        ("+856", "🇱🇦 +856"),   // Laos
        ("+371", "🇱🇻 +371"),   // Latvia
        ("+961", "🇱🇧 +961"),   // Lebanon
        ("+266", "🇱🇸 +266"),   // Lesotho
        ("+231", "🇱🇷 +231"),   // Liberia
        ("+218", "🇱🇾 +218"),   // Libya
        ("+423", "🇱🇮 +423"),   // Liechtenstein
        ("+370", "🇱🇹 +370"),   // Lithuania
        ("+352", "🇱🇺 +352"),   // Luxembourg
        ("+853", "🇲🇴 +853"),   // Macau
        ("+261", "🇲🇬 +261"),   // Madagascar
        ("+265", "🇲🇼 +265"),   // Malawi
        ("+60", "🇲🇾 +60"),     // Malaysia
        ("+960", "🇲🇻 +960"),   // Maldives
        ("+223", "🇲🇱 +223"),   // Mali
        ("+356", "🇲🇹 +356"),   // Malta
        ("+692", "🇲🇭 +692"),   // Marshall Islands
        ("+596", "🇲🇶 +596"),   // Martinique
        ("+222", "🇲🇷 +222"),   // Mauritania
        ("+230", "🇲🇺 +230"),   // Mauritius
        ("+262", "🇾🇹 +262"),   // Mayotte
        ("+52", "🇲🇽 +52"),     // Mexico
        ("+691", "🇫🇲 +691"),   // Micronesia
        ("+373", "🇲🇩 +373"),   // Moldova
        ("+377", "🇲🇨 +377"),   // Monaco
        ("+976", "🇲🇳 +976"),   // Mongolia
        ("+382", "🇲🇪 +382"),   // Montenegro
        ("+1664", "🇲🇸 +1664"), // Montserrat
        ("+212", "🇲🇦 +212"),   // Morocco
        ("+258", "🇲🇿 +258"),   // Mozambique
        ("+95", "🇲🇲 +95"),     // Myanmar
        ("+264", "🇳🇦 +264"),   // Namibia
        ("+674", "🇳🇷 +674"),   // Nauru
        ("+977", "🇳🇵 +977"),   // Nepal
        ("+31", "🇳🇱 +31"),     // Netherlands
        ("+687", "🇳🇨 +687"),   // New Caledonia
        ("+64", "🇳🇿 +64"),     // New Zealand
        ("+505", "🇳🇮 +505"),   // Nicaragua
        ("+227", "🇳🇪 +227"),   // Niger
        ("+234", "🇳🇬 +234"),   // Nigeria
        ("+683", "🇳🇺 +683"),   // Niue
        ("+850", "🇰🇵 +850"),   // North Korea
        ("+389", "🇲🇰 +389"),   // North Macedonia
        ("+1670", "🇲🇵 +1670"), // Northern Mariana Islands
        ("+47", "🇳🇴 +47"),     // Norway
        ("+968", "🇴🇲 +968"),   // Oman
        ("+92", "🇵🇰 +92"),     // Pakistan
        ("+680", "🇵🇼 +680"),   // Palau
        ("+970", "🇵🇸 +970"),   // Palestine
        ("+507", "🇵🇦 +507"),   // Panama
        ("+675", "🇵🇬 +675"),   // Papua New Guinea
        ("+595", "🇵🇾 +595"),   // Paraguay
        ("+51", "🇵🇪 +51"),     // Peru
        ("+63", "🇵🇭 +63"),     // Philippines
        ("+48", "🇵🇱 +48"),     // Poland
        ("+351", "🇵🇹 +351"),   // Portugal
        ("+1787", "🇵🇷 +1787"), // Puerto Rico
        ("+974", "🇶🇦 +974"),   // Qatar
        ("+40", "🇷🇴 +40"),     // Romania
        ("+7", "🇷🇺 +7"),       // Russia
        ("+250", "🇷🇼 +250"),   // Rwanda
        ("+590", "🇧🇱 +590"),   // Saint Barthélemy
        ("+1869", "🇰🇳 +1869"), // Saint Kitts and Nevis
        ("+1758", "🇱🇨 +1758"), // Saint Lucia
        ("+508", "🇵🇲 +508"),   // Saint Pierre and Miquelon
        ("+1784", "🇻🇨 +1784"), // Saint Vincent and the Grenadines
        ("+685", "🇼🇸 +685"),   // Samoa
        ("+378", "🇸🇲 +378"),   // San Marino
        ("+239", "🇸🇹 +239"),   // São Tomé and Príncipe
        ("+966", "🇸🇦 +966"),   // Saudi Arabia
        ("+221", "🇸🇳 +221"),   // Senegal
        ("+381", "🇷🇸 +381"),   // Serbia
        ("+248", "🇸🇨 +248"),   // Seychelles
        ("+232", "🇸🇱 +232"),   // Sierra Leone
        ("+65", "🇸🇬 +65"),     // Singapore
        ("+421", "🇸🇰 +421"),   // Slovakia
        ("+386", "🇸🇮 +386"),   // Slovenia
        ("+677", "🇸🇧 +677"),   // Solomon Islands
        ("+252", "🇸🇴 +252"),   // Somalia
        ("+27", "🇿🇦 +27"),     // South Africa
        ("+82", "🇰🇷 +82"),     // South Korea
        ("+211", "🇸🇸 +211"),   // South Sudan
        ("+34", "🇪🇸 +34"),     // Spain
        ("+94", "🇱🇰 +94"),     // Sri Lanka
        ("+249", "🇸🇩 +249"),   // Sudan
        ("+597", "🇸🇷 +597"),   // Suriname
        ("+46", "🇸🇪 +46"),     // Sweden
        ("+41", "🇨🇭 +41"),     // Switzerland
        ("+963", "🇸🇾 +963"),   // Syria
        ("+886", "🇹🇼 +886"),   // Taiwan
        ("+992", "🇹🇯 +992"),   // Tajikistan
        ("+255", "🇹🇿 +255"),   // Tanzania
        ("+66", "🇹🇭 +66"),     // Thailand
        ("+670", "🇹🇱 +670"),   // Timor-Leste
        ("+228", "🇹🇬 +228"),   // Togo
        ("+676", "🇹🇴 +676"),   // Tonga
        ("+1868", "🇹🇹 +1868"), // Trinidad and Tobago
        ("+216", "🇹🇳 +216"),   // Tunisia
        ("+90", "🇹🇷 +90"),     // Turkey
        ("+993", "🇹🇲 +993"),   // Turkmenistan
        ("+1649", "🇹🇨 +1649"), // Turks and Caicos Islands
        ("+688", "🇹🇻 +688"),   // Tuvalu
        ("+256", "🇺🇬 +256"),   // Uganda
        ("+380", "🇺🇦 +380"),   // Ukraine
        ("+971", "🇦🇪 +971"),   // United Arab Emirates
        ("+44", "🇬🇧 +44"),     // United Kingdom
        ("+1", "🇺🇸 +1"),       // United States
        ("+598", "🇺🇾 +598"),   // Uruguay
        ("+998", "🇺🇿 +998"),   // Uzbekistan
        ("+678", "🇻🇺 +678"),   // Vanuatu
        ("+379", "🇻🇦 +379"),   // Vatican City
        ("+58", "🇻🇪 +58"),     // Venezuela
        ("+84", "🇻🇳 +84"),     // Vietnam
        ("+681", "🇼🇫 +681"),   // Wallis and Futuna
        ("+967", "🇾🇪 +967"),   // Yemen
        ("+260", "🇿🇲 +260"),   // Zambia
        ("+263", "🇿🇼 +263"),   // Zimbabwe
    ]
    @State private var hasExisting = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showRemoveConfirm = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        Text("This person will be notified by email and SMS, and may be contacted regarding your account in an emergency.")
                            .font(AppFont.bodySmall())
                            .foregroundColor(Color.textSecondary)

                        VStack(alignment: .leading, spacing: Spacing.md) {
                            fieldLabel("Full name")
                            TextField("", text: $name)
                                .textFieldStyle()

                            fieldLabel("Relationship")
                            Menu {
                                ForEach(NextOfKinService.relationships, id: \.key) { item in
                                    Button(item.label) { relationship = item.key }
                                }
                            } label: {
                                HStack {
                                    Text(NextOfKinService.relationships.first(where: { $0.key == relationship })?.label ?? "Select")
                                        .foregroundColor(Color.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down").foregroundColor(Color.textSecondary)
                                }
                                .padding(Spacing.md)
                                .background(Color.backgroundDark1)
                                .cornerRadius(Spacing.radiusMedium)
                                .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
                            }

                            fieldLabel("Phone number")
                            HStack(spacing: Spacing.sm) {
                                Menu {
                                    ForEach(countryCodes, id: \.code) { item in
                                        Button(item.label) { countryCode = item.code }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(countryCodes.first(where: { $0.code == countryCode })?.label ?? countryCode)
                                            .font(AppFont.bodyRegular())
                                            .foregroundColor(Color.textPrimary)
                                            .lineLimit(1)
                                            .fixedSize()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.textSecondary)
                                    }
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.md)
                                    .background(Color.backgroundDark1)
                                    .cornerRadius(Spacing.radiusMedium)
                                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
                                }
                                
                                TextField("", text: $phone)
                                    .keyboardType(.phonePad)
                                    .textFieldStyle()
                            }

                            fieldLabel("Email address")
                            TextField("", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle()
                        }

                        Button(action: save) {
                            Text(hasExisting ? "Update Next of Kin" : "Save Next of Kin")
                                .font(AppFont.button())
                                .foregroundColor(Color.backgroundDark1)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.primaryGold)
                                .cornerRadius(Spacing.radiusMedium)
                        }
                        .padding(.top, Spacing.sm)

                        if hasExisting {
                            Button(action: { showRemoveConfirm = true }) {
                                Text("Remove Next of Kin")
                                    .font(AppFont.button())
                                    .foregroundColor(.errorRed)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(.errorRed, lineWidth: 1))
                            }
                        }
                    }
                    .padding(Spacing.screenHorizontal)
                }
            }
            .navigationTitle("Next of Kin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(Color.primaryGold)
                }
            }
            .overlay { if isLoading { LoadingOverlay() } }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
            .alert("Remove Next of Kin", isPresented: $showRemoveConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive) { remove() }
            } message: {
                Text("They will be notified that they've been removed. Continue?")
            }
            .onAppear(perform: load)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text).font(AppFont.bodySmall()).foregroundColor(Color.textSecondary)
    }

    private func load() {
        isLoading = true
        Task {
            do {
                if let kin = try await NextOfKinService.shared.get() {
                    name = kin.name
                    relationship = kin.relationship
                    email = kin.email
                    if let matched = countryCodes.first(where: { kin.phoneNumber.hasPrefix($0.code) }) {
                        countryCode = matched.code
                        phone = String(kin.phoneNumber.dropFirst(matched.code.count))
                    } else {
                        phone = kin.phoneNumber
                    }
                    hasExisting = true
                }
            } catch {
                // no existing kin, or fetch failed silently — form stays empty
            }
            isLoading = false
        }
    }

    private func save() {
        guard !name.isEmpty, !phone.isEmpty, !email.isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        let fullPhone = phone.hasPrefix("+") ? phone : "\(countryCode)\(phone)"
        isLoading = true
        Task {
            do {
                _ = try await NextOfKinService.shared.save(name: name, relationship: relationship, phone: fullPhone, email: email)
                hasExisting = true
                isLoading = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func remove() {
        isLoading = true
        Task {
            do {
                try await NextOfKinService.shared.delete()
                isLoading = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

private extension View {
    func textFieldStyle() -> some View {
        self
            .foregroundColor(Color.textPrimary)
            .padding(Spacing.md)
            .background(Color.backgroundDark1)
            .cornerRadius(Spacing.radiusMedium)
            .overlay(RoundedRectangle(cornerRadius: Spacing.radiusMedium).stroke(Color.borderDefault, lineWidth: 1))
    }
}
