import SwiftUI

struct AppHeader: View {
    @Binding var isSearching: Bool
    @Binding var searchText: String
    
    var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                ExpandableSearchBar(
                    searchText: $searchText,
                    isSearching: $isSearching
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                LogoHeader(onSearchPressed: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = true
                    }
                })
            }
            
            Divider()
        }
        .background(AppColors.background)
    }
}

#Preview {
    VStack {
        AppHeader(isSearching: .constant(false), searchText: .constant(""))
        Spacer()
    }
    .background(AppColors.background)
}
