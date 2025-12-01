//
//  SignUpFormView.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct SignUpFormView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var email: String
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var showPassword: Bool
    @Binding var showConfirmPassword: Bool

    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Back Button & Title
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }

                Spacer()

                Text("Sign Up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                }
                .foregroundColor(.clear)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                TextField("Enter your email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            // First Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("First Name")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                TextField("Enter your first name", text: $firstName)
                    .textContentType(.givenName)
                    .autocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            // Last Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Name")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                TextField("Enter your last name", text: $lastName)
                    .textContentType(.familyName)
                    .autocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                HStack {
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("Enter your password", text: $password)
                            .textContentType(.password)
                    }

                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(12)
                .background(AppColors.secondaryBackground)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            // Confirm Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                HStack {
                    if showConfirmPassword {
                        TextField("Confirm your password", text: $confirmPassword)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textContentType(.password)
                    }

                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(12)
                .background(AppColors.secondaryBackground)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            // Password Mismatch Error
            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Passwords do not match")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.red)
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 16)
            }

            // Error Message from API
            if let errorMessage = authManager.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.red)
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 16)
            }

            // Sign Up Button
            Button(action: signUpAction) {
                if authManager.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Creating account...")
                    }
                } else {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(AppColors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword)
            .opacity(authManager.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword ? 0.6 : 1)
            .padding(.horizontal, 16)
        }
    }

    private func signUpAction() {
        Task {
            await authManager.signup(email: email, firstName: firstName, lastName: lastName, password: password)
        }
    }
}

#Preview {
    SignUpFormView(
        email: .constant(""),
        firstName: .constant(""),
        lastName: .constant(""),
        password: .constant(""),
        confirmPassword: .constant(""),
        showPassword: .constant(false),
        showConfirmPassword: .constant(false),
        onBack: {}
    )
    .environmentObject(AuthenticationManager())
}
