import SwiftUI

struct TabBarIcon: View {
    let iconName: String
    let label: String
    let isSelected: Bool
    let notificationCount: Int?
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? AppColors.primaryBlue : AppColors.tabBarInactive)
                
                if let count = notificationCount, count > 0 {
                    NotificationBadge(count: count)
                }
            }
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isSelected ? AppColors.primaryBlue : AppColors.tabBarInactive)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        TabBarIcon(iconName: "house.fill", label: "Home", isSelected: true, notificationCount: nil)
        TabBarIcon(iconName: "magnifyingglass", label: "Search", isSelected: false, notificationCount: nil)
        TabBarIcon(iconName: "person.fill", label: "Profile", isSelected: false, notificationCount: 5)
    }
    .padding()
    .background(AppColors.tabBarBackground)
}
