//
//  EmptyStateView.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primaryBlue)

            Text("Not Logged In")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text("Please login or sign up to continue")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

#Preview {
    EmptyStateView()
}
