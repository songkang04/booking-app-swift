//
//  ProfileMenuRow.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isDestructive ? .red : AppColors.primaryBlue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDestructive ? .red : AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 12) {
        ProfileMenuRow(
            icon: "heart.fill",
            title: "Saved Items",
            subtitle: "View your saved bookings"
        )

        ProfileMenuRow(
            icon: "rectangle.portrait.and.arrow.right",
            title: "Logout",
            subtitle: "Sign out of your account",
            isDestructive: true
        )
    }
    .padding(.horizontal, 16)
}
