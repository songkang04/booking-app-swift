import SwiftUI

struct PhotoCard: View {
    let photo: Photo
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail Image
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.secondaryBackground)
                    .frame(height: 150)
                    .overlay(
                        isLoading ? AnyView(ProgressView()
                            .tint(AppColors.primaryBlue)) : AnyView(EmptyView())
                    )
            }
            
            // Title
            Text(photo.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
            
            // Album ID
            Text("Album #\(photo.albumId)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            print("🖼️ [DEBUG] PhotoCard appeared - ID: \(photo.id), Title: \(photo.title)")
            loadImage()
        }
    }
    
    private func loadImage() {
        print("🖼️ [DEBUG] Loading image for photo: \(photo.title)")
        Task {
            guard let url = URL(string: photo.thumbnailUrl) else {
                print("🖼️ [ERROR] Invalid URL: \(photo.thumbnailUrl)")
                isLoading = false
                return
            }
            
            print("🖼️ [DEBUG] Starting image download from: \(url)")
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                print("🖼️ [DEBUG] Downloaded \(data.count) bytes")
                if let uiImage = UIImage(data: data) {
                    print("🖼️ [DEBUG] Image created successfully: size \(uiImage.size), orientation: \(uiImage.imageOrientation.rawValue)")
                    await MainActor.run {
                        self.image = uiImage
                        self.isLoading = false
                        print("🖼️ [DEBUG] Image set on main thread")
                    }
                } else {
                    print("🖼️ [ERROR] Failed to create UIImage from data")
                    isLoading = false
                }
            } catch {
                print("🖼️ [ERROR] Image download failed: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    PhotoCard(photo: Photo(
        id: 1,
        albumId: 1,
        title: "accusamus beatae ad facilis cum similique qui sunt",
        url: "https://via.placeholder.com/600/92c952",
        thumbnailUrl: "https://via.placeholder.com/150/92c952"
    ))
    .padding()
}
