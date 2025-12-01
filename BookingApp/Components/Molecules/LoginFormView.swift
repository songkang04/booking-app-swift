//
//  LoginFormView.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct LoginFormView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var email: String
    @Binding var password: String
    @Binding var showPassword: Bool
    @Binding var showLoginForm: Bool

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

                Text("Login")
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

            // Error Message
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

            // Login Button
            Button(action: loginAction) {
                if authManager.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Logging in...")
                    }
                } else {
                    Text("Login")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(AppColors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
            .opacity(authManager.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1)
            .padding(.horizontal, 16)
        }
    }

    private func loginAction() {
        Task {
            await authManager.login(email: email, password: password)
        }
    }
}

#Preview {
    LoginFormView(
        email: .constant(""),
        password: .constant(""),
        showPassword: .constant(false),
        showLoginForm: .constant(true),
        onBack: {}
    )
    .environmentObject(AuthenticationManager())
}
