//
//  EditProfileView.swift
//  AfriVest
//
//  Created by Kato Drake Smith on 27/12/2025.
//


import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Avatar Section
                    VStack(spacing: Spacing.md) {
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let avatarUrl = viewModel.avatarUrl,
                                  !avatarUrl.isEmpty {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                initialsAvatar
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            initialsAvatar
                        }
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Text("Change Photo")
                                .font(AppFont.bodyRegular())
                                .foregroundColor(Color.primaryGold)
                        }
                        .onChange(of: selectedPhotoItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    viewModel.selectedImage = uiImage
                                }
                            }
                        }
                        
                        if viewModel.avatarUrl != nil && viewModel.selectedImage == nil {
                            Button("Remove Photo") {
                                viewModel.deleteAvatar()
                            }
                            .font(AppFont.bodySmall())
                            .foregroundColor(.errorRed)
                        }
                    }
                    .padding(.vertical, Spacing.lg)
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Full Name")
                            .font(AppFont.bodySmall())
                            .foregroundColor(Color.textSecondary)
                        
                        TextField("Enter your name", text: $viewModel.name)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(Color.textPrimary)
                            .padding(Spacing.md)
                            .background(Color.inputBackground)
                            .cornerRadius(Spacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                    .stroke(Color.borderDefault, lineWidth: 1)
                            )
                    }
                    
                    // Phone Field
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Phone Number")
                            .font(AppFont.bodySmall())
                            .foregroundColor(Color.textSecondary)
                        
                        TextField("Enter phone number", text: $viewModel.phoneNumber)
                            .font(AppFont.bodyLarge())
                            .foregroundColor(Color.textPrimary)
                            .keyboardType(.phonePad)
                            .padding(Spacing.md)
                            .background(Color.inputBackground)
                            .cornerRadius(Spacing.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                                    .stroke(Color.borderDefault, lineWidth: 1)
                            )
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(AppFont.bodySmall())
                            .foregroundColor(.errorRed)
                    }
                    
                    Spacer()
                    
                    // Save Button
                    PrimaryButton(
                        title: "Save Changes",
                        action: {
                            viewModel.updateProfile {
                                dismiss()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.hasChanges
                    )
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadProfile()
        }
    }
    
    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.primaryGold.opacity(0.2))
                .frame(width: 100, height: 100)
            
            Text(viewModel.getInitials())
                .font(AppFont.heading2())
                .foregroundColor(Color.primaryGold)
        }
    }
}
