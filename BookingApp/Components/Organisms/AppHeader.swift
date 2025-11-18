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
                .onAppear {
                    print("🔍 [DEBUG] ExpandableSearchBar appeared")
                }
            } else {
                LogoHeader(onSearchPressed: {
                    print("🔍 [DEBUG] Search button pressed")
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = true
                        print("🔍 [DEBUG] isSearching set to true")
                    }
                })
                .onAppear {
                    print("🔍 [DEBUG] LogoHeader appeared")
                }
            }
            
            Divider()
        }
        .background(AppColors.background)
        .onChange(of: isSearching) { oldValue, newValue in
            print("🔍 [DEBUG] isSearching changed from \(oldValue) to \(newValue)")
        }
    }
}

#Preview {
    VStack {
        AppHeader(isSearching: .constant(false), searchText: .constant(""))
        Spacer()
    }
    .background(AppColors.background)
}
