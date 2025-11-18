import SwiftUI

struct HomeScreen: View {
    @State private var photos: [Photo] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 10) {
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
                        .padding(16)
                    
                    // Loading State
                    if isLoading {
                        VStack {
                            ProgressView()
                                .tint(AppColors.primaryBlue)
                            Text("Loading photos...")
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
                            
                            Button(action: loadPhotos) {
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
                    
                    // Photos Grid
                    if !photos.isEmpty {
                        VStack(spacing: 12) {
                            Text("Latest Photos")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                            
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ],
                                spacing: 12
                            ) {
                                ForEach(photos) { photo in
                                    PhotoCard(photo: photo)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .background(AppColors.background)
        .onAppear {
            loadPhotos()
        }
    }
    
    private func loadPhotos() {
        print("🏠 [DEBUG] HomeScreen.loadPhotos() started")
        Task {
            isLoading = true
            errorMessage = nil
            print("🏠 [DEBUG] Loading state set to true")
            
            do {
                print("🏠 [DEBUG] Fetching photos from API...")
                let fetchedPhotos = try await APIService.shared.fetchPhotos(limit: 10)
                print("🏠 [DEBUG] Fetched \(fetchedPhotos.count) photos successfully")
                await MainActor.run {
                    self.photos = fetchedPhotos
                    self.isLoading = false
                    print("🏠 [DEBUG] Photos updated on main thread, isLoading set to false")
                }
            } catch {
                print("🏠 [ERROR] Failed to fetch photos: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("🏠 [DEBUG] Error state updated on main thread")
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
        .background(AppColors.background)
}
