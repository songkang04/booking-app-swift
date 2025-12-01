//
//  NotLoggedInView.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct NotLoggedInView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var showLoginForm: Bool = false
    @State private var showSignUpForm: Bool = false
    @State private var showOTPVerification: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Show appropriate view based on state
                if showOTPVerification || authManager.requiresOTPVerification {
                    OTPVerificationView(
                        email: authManager.pendingVerificationEmail.isEmpty ? email : authManager.pendingVerificationEmail,
                        onBack: {
                            showOTPVerification = false
                            authManager.requiresOTPVerification = false
                            authManager.pendingVerificationEmail = ""
                            authManager.errorMessage = nil
                        },
                        onVerifySuccess: {
                            resetForm()
                            showOTPVerification = false
                            showSignUpForm = false
                        }
                    )
                } else if showLoginForm {
                    LoginFormView(
                        email: $email,
                        password: $password,
                        showPassword: $showPassword,
                        showLoginForm: $showLoginForm,
                        onBack: {
                            resetForm()
                            showLoginForm = false
                        }
                    )
                } else if showSignUpForm {
                    SignUpFormView(
                        email: $email,
                        firstName: $firstName,
                        lastName: $lastName,
                        password: $password,
                        confirmPassword: $confirmPassword,
                        showPassword: $showPassword,
                        showConfirmPassword: $showConfirmPassword,
                        onBack: {
                            resetForm()
                            showSignUpForm = false
                        }
                    )
                } else {
                    // Empty State & Auth Buttons
                    VStack(spacing: 32) {
                        EmptyStateView()

                        AuthButtonsView(
                            onLoginTapped: { showLoginForm = true },
                            onSignUpTapped: { showSignUpForm = true }
                        )
                    }
                    .padding(.vertical, 40)
                }

                Spacer()
            }
            .padding(.top, 40)
        }
        .background(AppColors.background)
        .onChange(of: authManager.requiresOTPVerification) { _, newValue in
            if newValue {
                showOTPVerification = true
            }
        }
    }

    // MARK: - Helper Methods
    private func resetForm() {
        email = ""
        firstName = ""
        lastName = ""
        password = ""
        confirmPassword = ""
        showPassword = false
        showConfirmPassword = false
        authManager.errorMessage = nil
    }
}

#Preview {
    NotLoggedInView()
        .environmentObject(AuthenticationManager())
}
