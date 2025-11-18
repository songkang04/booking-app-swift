import SwiftUI

struct ProfileScreen: View {
    var body: some View {
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
                    
                    Text("John Doe")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("john.doe@example.com")
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
                    
                    ProfileMenuRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Logout",
                        subtitle: "Sign out of your account",
                        isDestructive: true
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .background(AppColors.background)
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
    ProfileScreen()
}
