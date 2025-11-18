import SwiftUI

struct ExpandableSearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    var onDismiss: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SearchField(text: $searchText)
                
                if isSearching {
                    Button("Cancel") {
                        print("🔍 [DEBUG] Cancel button pressed in ExpandableSearchBar")
                        searchText = ""
                        isSearching = false
                        print("🔍 [DEBUG] Search dismissed, isSearching set to false")
                        onDismiss()
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppColors.primaryBlue)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    VStack {
        ExpandableSearchBar(searchText: .constant(""), isSearching: .constant(false))
        Spacer()
    }
    .background(AppColors.background)
}
