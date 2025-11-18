import SwiftUI

struct SearchScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Search Results")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // Sample search results
                    VStack(spacing: 12) {
                        ForEach(0..<8, id: \.self) { index in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.secondaryBackground)
                                    .frame(width: 80, height: 80)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Result \(index + 1)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Search result description")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                        .lineLimit(2)
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 12))
                                        Text("4.5")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(AppColors.secondaryBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(AppColors.background)
    }
}

#Preview {
    SearchScreen()
}
