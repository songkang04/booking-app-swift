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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Empty State Icon - only show when not in form
                if !showLoginForm && !showSignUpForm {
                    VStack(spacing: 16) {
                        Image(systemName: "person.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.textTertiary)

                        Text("Not Logged In")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Please log in to access your profile and bookings")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                }

                // Show Login/Signup Buttons if no form is shown
                if !showLoginForm && !showSignUpForm {
                    VStack(spacing: 12) {
                        Button(action: { showLoginForm = true }) {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(AppColors.primaryBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        Button(action: { showSignUpForm = true }) {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(AppColors.lightBlue)
                                .foregroundColor(AppColors.primaryBlue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.primaryBlue, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                } else if showLoginForm {
                    // Login Form
                    loginFormView()
                } else if showSignUpForm {
                    // Sign Up Form
                    signUpFormView()
                }

                Spacer()
            }
            .padding(.top, 40)
        }
        .background(AppColors.background)
    }

    // MARK: - Login Form View
    @ViewBuilder
    private func loginFormView() -> some View {
        VStack(spacing: 16) {
            // Back Button & Title
            HStack {
                Button(action: {
                    showLoginForm = false
                    resetForm()
                }) {
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

                // Invisible spacer for alignment
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

    // MARK: - Sign Up Form View
    @ViewBuilder
    private func signUpFormView() -> some View {
        VStack(spacing: 16) {
            // Back Button & Title
            HStack {
                Button(action: {
                    showSignUpForm = false
                    resetForm()
                }) {
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

                // Invisible spacer for alignment
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

    // MARK: - Helper Methods
    private func loginAction() {
        Task {
            await authManager.login(email: email, password: password)
        }
    }

    private func signUpAction() {
        Task {
            await authManager.signup(email: email, firstName: firstName, lastName: lastName, password: password)
        }
    }

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
