import SwiftUI

struct NotificationBadge: View {
    let count: Int
    
    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.white)
            .frame(minWidth: 16, minHeight: 16)
            .padding(.horizontal, 4)
            .background(Color.red)
            .cornerRadius(8)
            .offset(x: 4, y: -4)
    }
}

#Preview {
    HStack(spacing: 20) {
        NotificationBadge(count: 1)
        NotificationBadge(count: 9)
        NotificationBadge(count: 99)
        NotificationBadge(count: 100)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
