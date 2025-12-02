import SwiftUI

struct TabBarItem: View {
    let tab: Tab
    let isSelected: Bool
    var notificationCount: Int? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            TabBarIcon(
                iconName: tab.iconName,
                label: tab.label,
                isSelected: isSelected,
                notificationCount: notificationCount
            )
            .frame(maxWidth: .infinity)
        }
    }
}

enum Tab: CaseIterable {
    case home
    case search
    case bookings
    case profile

    var iconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .search:
            return "magnifyingglass"
        case .bookings:
            return "calendar.badge.clock"
        case .profile:
            return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .home:
            return "Home"
        case .search:
            return "Search"
        case .bookings:
            return "Bookings"
        case .profile:
            return "Profile"
        }
    }
}

#Preview {
    HStack(spacing: 0) {
        TabBarItem(tab: .home, isSelected: true, action: {})
        TabBarItem(tab: .search, isSelected: false, action: {})
        TabBarItem(tab: .profile, isSelected: false, notificationCount: 3, action: {})
    }
    .background(AppColors.tabBarBackground)
    .frame(height: 60)
}
