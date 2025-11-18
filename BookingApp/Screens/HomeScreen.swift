import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 16) {
                    // Featured Banner
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.lightBlue)
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Text("Welcome Home")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppColors.primaryBlue)
                            }
                        )
                        .padding(.horizontal, 16)
                    
                    // Sample content
                    VStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { index in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(AppColors.secondaryBackground)
                                    .frame(width: 50, height: 50)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Item \(index + 1)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Description for item \(index + 1)")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .background(AppColors.background)
    }
}

#Preview {
    HomeScreen()
}
