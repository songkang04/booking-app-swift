//
//  ProfileScreen.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        if authManager.isLoggedIn, let user = authManager.currentUser {
            // User is logged in - show profile
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
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
                    
                    // Profile Sections
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
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(AppColors.background)
            .alert("Confirm Logout", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
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
