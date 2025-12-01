//
//  AuthButtonsView.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct AuthButtonsView: View {
    var onLoginTapped: () -> Void
    var onSignUpTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Login Button
            Button(action: onLoginTapped) {
                Text("Login")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppColors.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // Sign Up Button
            Button(action: onSignUpTapped) {
                Text("Sign Up")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.clear)
                    .foregroundColor(AppColors.primaryBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.primaryBlue, lineWidth: 1.5)
                    )
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    AuthButtonsView(
        onLoginTapped: {},
        onSignUpTapped: {}
    )
}
