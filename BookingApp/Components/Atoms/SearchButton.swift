import SwiftUI

struct SearchButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 36, height: 36)
                .contentShape(Circle())
        }
    }
}

#Preview {
    SearchButton(action: {})
        .background(AppColors.background)
}
