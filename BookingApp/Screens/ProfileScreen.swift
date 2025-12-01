//
//  ProfileScreen.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        if authManager.isLoggedIn, let user = authManager.currentUser {
            // User is logged in - show profile
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeader(user: user)
                    ProfileMenuSection(onLogout: {
                        authManager.logout()
                    })
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(AppColors.background)
            .onAppear {
                print("👤 [DEBUG] ProfileScreen appeared - Logged in as \(user.email)")
            }
        } else {
            // User is not logged in - show login view
            NotLoggedInView()
                .environmentObject(authManager)
                .onAppear {
                    print("👤 [DEBUG] ProfileScreen appeared - Not logged in")
                }
        }
    }
}

#Preview {
    let authManager = AuthenticationManager()
    authManager.currentUser = User(
        id: UUID().uuidString,
        email: "demo@example.com",
        name: "Demo User",
        avatar: nil
    )
    authManager.isLoggedIn = true

    return ProfileScreen()
        .environmentObject(authManager)
}
