import SwiftUI

struct HomeScreen: View {
    @State private var homestays: [Homestay] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 10) {
            ScrollView {
                VStack(spacing: 16) {
                    // Featured Banner - Welcome Section
                    ZStack {
                        // Background with gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.primaryBlue.opacity(0.8),
                                AppColors.primaryBlue.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Decorative circles
                        Circle()
                            .fill(AppColors.primaryBlue.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .offset(x: 80, y: -40)
                        
                        Circle()
                            .fill(AppColors.primaryBlue.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .offset(x: -70, y: 50)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                
                                Text("Welcome!")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            Text("Discover amazing homestays and start your adventure")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                            
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("500+")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Properties")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Divider()
                                    .frame(height: 30)
                                    .opacity(0.5)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("4.8★")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Rating")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(20)
                    }
                    .frame(height: 180)
                    .cornerRadius(16)
                    .padding(16)
                    
                    // Loading State
                    if isLoading {
                        VStack {
                            ProgressView()
                                .tint(AppColors.primaryBlue)
                            Text("Loading homestays...")
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                    }
                    
                    // Error State
                    if let errorMessage = errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 32))
                                .foregroundColor(.red)
                            Text("Error")
                                .font(.system(size: 16, weight: .semibold))
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Button(action: loadHomestays) {
                                Text("Retry")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(AppColors.primaryBlue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(16)
                    }
                    
                    // Homestays Horizontal Scroll
                    if !homestays.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Latest Homestays")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(homestays) { homestay in
                                        HomestayCard(homestay: homestay)
                                            .frame(width: 280)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
        }
        .background(AppColors.background)
        .onAppear {
            loadHomestays()
        }
    }
    
    private func loadHomestays() {
        print("🏠 [HomeScreen] Starting to load homestays...")
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                print("🏠 [HomeScreen] Calling APIService.fetchHomestays()...")
                let fetchedHomestays = try await APIService.shared.fetchHomestays(limit: 10)
                
                print("🏠 [HomeScreen] Received \(fetchedHomestays.count) homestays")
                
                await MainActor.run {
                    print("🏠 [HomeScreen] Updating UI with \(fetchedHomestays.count) homestays")
                    self.homestays = fetchedHomestays
                    self.isLoading = false
                }
            } catch {
                print("🏠 [HomeScreen] Error loading homestays: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
        .background(AppColors.background)
}
