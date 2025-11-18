import SwiftUI

struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onClear: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textTertiary)
                .font(.system(size: 14, weight: .semibold))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular))
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.secondaryBackground)
        .cornerRadius(20)
    }
}

#Preview {
    VStack {
        SearchField(text: .constant(""))
        SearchField(text: .constant("hello"))
    }
    .padding()
    .background(AppColors.background)
}
