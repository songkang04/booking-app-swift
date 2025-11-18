import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: Tab
    var profileNotificationCount: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                TabBarItem(
                    tab: .home,
                    isSelected: selectedTab == .home,
                    action: { selectedTab = .home }
                )
                
                TabBarItem(
                    tab: .search,
                    isSelected: selectedTab == .search,
                    action: { selectedTab = .search }
                )
                
                TabBarItem(
                    tab: .profile,
                    isSelected: selectedTab == .profile,
                    notificationCount: profileNotificationCount,
                    action: { selectedTab = .profile }
                )
            }
            .frame(height: 60)
            .background(AppColors.tabBarBackground)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        BottomTabBar(selectedTab: .constant(.home))
    }
    .background(AppColors.background)
}
