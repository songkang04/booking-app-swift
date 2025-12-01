//
//  ProfileMenuSection.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct ProfileMenuSection: View {
    @State private var showLogoutConfirmation = false
    var onLogout: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ProfileMenuRow(
                icon: "heart.fill",
                title: "Saved Items",
                subtitle: "View your saved bookings"
            )

            ProfileMenuRow(
                icon: "calendar",
                title: "My Bookings",
                subtitle: "Manage your reservations"
            )

            ProfileMenuRow(
                icon: "gearshape.fill",
                title: "Settings",
                subtitle: "Account preferences"
            )

            ProfileMenuRow(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                subtitle: "Get help when you need it"
            )

            Button(action: { showLogoutConfirmation = true }) {
                ProfileMenuRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    isDestructive: true
                )
            }
        }
        .padding(.horizontal, 16)
        .alert("Confirm Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                onLogout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

#Preview {
    ProfileMenuSection(onLogout: {})
}
