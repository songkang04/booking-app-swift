import SwiftUI

struct BookingOTPVerificationView: View {
    let booking: Booking
    let onSuccess: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var otpCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isVerified = false
    @FocusState private var isOTPFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primaryBlue)
            
            // Title
            Text("Verify Your Booking")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // Description
            Text("We've sent a verification code to your email. Please enter it below to confirm your booking.")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Booking Info
            VStack(spacing: 8) {
                Text(booking.homestayName ?? "Homestay")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(booking.formattedCheckIn) - \(booking.formattedCheckOut)")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(16)
            .background(AppColors.secondaryBackground)
            .cornerRadius(12)
            .padding(.horizontal, 32)
            
            // OTP Input
            TextField("Enter 6-digit code", text: $otpCode)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primaryBlue.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 48)
                .focused($isOTPFocused)
                .onChange(of: otpCode) { _, newValue in
                    // Limit to 6 digits
                    if newValue.count > 6 {
                        otpCode = String(newValue.prefix(6))
                    }
                    // Filter non-digits
                    otpCode = newValue.filter { $0.isNumber }
                }
            
            // Error Message
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // Verify Button
            Button(action: verifyOTP) {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Verify & Confirm Booking")
                    }
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(otpCode.count == 6 ? AppColors.primaryBlue : AppColors.primaryBlue.opacity(0.5))
                .cornerRadius(12)
            }
            .disabled(otpCode.count != 6 || isLoading)
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .background(AppColors.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .onAppear {
            isOTPFocused = true
        }
        .alert("Booking Confirmed!", isPresented: $isVerified) {
            Button("OK") {
                onSuccess()
            }
        } message: {
            Text("Your booking has been confirmed. You can view it in your bookings.")
        }
    }
    
    private func verifyOTP() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                try await APIService.shared.verifyBookingOTP(bookingId: booking.id, otp: otpCode)
                
                await MainActor.run {
                    isLoading = false
                    isVerified = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

