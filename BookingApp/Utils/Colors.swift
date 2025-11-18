import SwiftUI
import UIKit

struct AppColors {
    // Primary colors (Facebook-like blue)
    static let primaryBlue = Color(red: 0, green: 0.48, blue: 0.98)
    static let lightBlue = Color(red: 0.95, green: 0.96, blue: 1)
    
    // Neutral colors
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiary = Color(UIColor.tertiarySystemBackground)
    
    // Text colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    // Separator
    static let separator = Color(UIColor.separator)
    
    // Status colors
    static let online = Color.green
    static let offline = Color.gray
    
    // Tab bar
    static let tabBarBackground = Color(UIColor.systemBackground)
    static let tabBarInactive = Color(UIColor.secondaryLabel)
    static let tabBarActive = primaryBlue
}

extension Color {
    static let fbPrimary = AppColors.primaryBlue
    static let fbBackground = AppColors.background
}

// MARK: - ViewModifiers

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
