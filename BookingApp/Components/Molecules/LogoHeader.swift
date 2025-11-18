import SwiftUI

struct LogoHeader: View {
    var onSearchPressed: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            LogoBrand()
            
            Spacer()
            
            SearchButton(action: onSearchPressed)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    LogoHeader(onSearchPressed: {})
        .background(AppColors.background)
}
