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
                    action: {
                        print("📍 [DEBUG] Home tab tapped")
                        selectedTab = .home
                    }
                )

                TabBarItem(
                    tab: .search,
                    isSelected: selectedTab == .search,
                    action: {
                        print("📍 [DEBUG] Search tab tapped")
                        selectedTab = .search
                    }
                )

                TabBarItem(
                    tab: .bookings,
                    isSelected: selectedTab == .bookings,
                    action: {
                        print("📍 [DEBUG] Bookings tab tapped")
                        selectedTab = .bookings
                    }
                )

                TabBarItem(
                    tab: .profile,
                    isSelected: selectedTab == .profile,
                    notificationCount: profileNotificationCount,
                    action: {
                        print("📍 [DEBUG] Profile tab tapped")
                        selectedTab = .profile
                    }
                )
            }
            .frame(height: 60)
            .background(AppColors.tabBarBackground)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            print("📍 [DEBUG] BottomTabBar: selectedTab changed from \(oldValue) to \(newValue)")
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
