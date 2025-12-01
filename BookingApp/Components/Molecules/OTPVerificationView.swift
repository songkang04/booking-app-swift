//
//  OTPVerificationView.swift
//  BookingApp
//
//  Created by Tien Nguyen on 1/12/25.
//

import SwiftUI

struct OTPVerificationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    let email: String
    var onBack: () -> Void
    var onVerifySuccess: () -> Void
    
    @State private var otpCode: String = ""
    @State private var isVerifying: Bool = false
    @FocusState private var isOTPFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
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
                
                Text("Verify OTP")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // Invisible placeholder for alignment
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                }
                .foregroundColor(.clear)
            }
            .padding(.horizontal, 16)
            
            // Icon
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primaryBlue)
                .padding(.top, 20)
            
            // Description
            VStack(spacing: 8) {
                Text("Enter verification code")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We've sent a 6-digit code to")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(email)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryBlue)
            }
            
            // OTP Input Field
            TextField("Enter 6-digit code", text: $otpCode)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .focused($isOTPFieldFocused)
                .onChange(of: otpCode) { _, newValue in
                    // Limit to 6 digits
                    if newValue.count > 6 {
                        otpCode = String(newValue.prefix(6))
                    }
                    // Only allow numbers
                    otpCode = newValue.filter { $0.isNumber }
                }
            
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
            
            // Verify Button
            Button(action: verifyOTP) {
                if isVerifying || authManager.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Verifying...")
                    }
                } else {
                    Text("Verify")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(otpCode.count == 6 ? AppColors.primaryBlue : AppColors.primaryBlue.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(otpCode.count != 6 || isVerifying || authManager.isLoading)
            .padding(.horizontal, 16)
            
            // Resend Code
            Button(action: resendOTP) {
                Text("Didn't receive the code? Resend")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.primaryBlue)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .onAppear {
            isOTPFieldFocused = true
        }
    }
    
    private func verifyOTP() {
        Task {
            await authManager.verifyOTP(email: email, otp: otpCode)
            if authManager.isLoggedIn {
                onVerifySuccess()
            }
        }
    }
    
    private func resendOTP() {
        Task {
            await authManager.resendOTP(email: email)
        }
    }
}

#Preview {
    OTPVerificationView(
        email: "test@example.com",
        onBack: {},
        onVerifySuccess: {}
    )
    .environmentObject(AuthenticationManager())
}

