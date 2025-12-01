//
//  ProfileHeader.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct ProfileHeader: View {
    let user: User

    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(AppColors.lightBlue)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primaryBlue)
                )

            Text(user.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(user.email)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    ProfileHeader(
        user: User(
            id: "123",
            email: "demo@example.com",
            name: "Demo User",
            avatar: nil
        )
    )
}
