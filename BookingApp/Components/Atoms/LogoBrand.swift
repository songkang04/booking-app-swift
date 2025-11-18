import SwiftUI

struct LogoBrand: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "book.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.primaryBlue)
            
            Text("Booking")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

#Preview {
    LogoBrand()
        .padding()
        .background(AppColors.background)
}
