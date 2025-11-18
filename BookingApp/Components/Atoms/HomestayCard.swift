import SwiftUI

struct HomestayCard: View {
    let homestay: Homestay
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail Image with overlay
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.secondaryBackground)
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if isLoading {
                    ProgressView()
                        .tint(AppColors.primaryBlue)
                }
                
                // Heart Icon
                Button(action: {}) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(.top, 18)
                .padding(.trailing, 8)
            }
            .frame(height: 160)
            .clipped()
            .cornerRadius(12)
            
            // Card Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(homestay.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.primaryBlue)
                    
                    Text(homestay.city)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
                
                // Info Row (Capacity, Bedrooms)
                HStack(spacing: 12) {
                    HStack(spacing: 2) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("\(homestay.bedroomCount)")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("\(homestay.capacity)")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // Rating and Price Row
                HStack {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.1f", homestay.rating))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("(\(homestay.reviewCount))")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Price
                    Text("₫ \(homestay.price)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .onAppear {
            print("🏠 [HomestayCard] Card appeared - Homestay: \(homestay.name) (ID: \(homestay.id))")
            print("🏠 [HomestayCard] Image URLs: \(homestay.images)")
            loadImage()
        }
    }
    
    private func loadImage() {
        print("🏠 [HomestayCard] Starting image load for: \(homestay.name)")
        
        Task {
            do {
                guard let urlString = homestay.images.first,
                      let url = URL(string: urlString) else {
                    print("❌ [HomestayCard] No valid image URL found in homestay")
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return
                }
                
                print("⏳ [HomestayCard] Downloading image from: \(urlString)")
                
                let (data, response) = try await URLSession.shared.data(from: url)
                
                print("📊 [HomestayCard] Downloaded \(data.count) bytes")
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ [HomestayCard] Invalid response type")
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return
                }
                
                print("📊 [HomestayCard] HTTP Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    print("❌ [HomestayCard] HTTP Error: \(httpResponse.statusCode)")
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return
                }
                
                if let uiImage = UIImage(data: data) {
                    print("🖼️ [HomestayCard] Image created - Size: \(uiImage.size), Orientation: \(uiImage.imageOrientation.rawValue), Scale: \(uiImage.scale)")
                    await MainActor.run {
                        self.image = uiImage
                        self.isLoading = false
                        print("✅ [HomestayCard] Image set on main thread successfully")
                    }
                } else {
                    print("❌ [HomestayCard] Failed to create UIImage from data (\(data.count) bytes)")
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                print("❌ DEBUG: Error loading image: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    HomestayCard(homestay: Homestay(
        id: "1",
        name: "Sample Homestay",
        description: "A beautiful place",
        address: "123 Main St",
        city: "City",
        province: "Province",
        country: "Country",
        images: ["https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&auto=format&fit=crop&q=60"],
        price: 500000,
        capacity: 4,
        bedroomCount: 2,
        bathroomCount: 1,
        amenities: ["Wifi", "AC"],
        rating: 4.5,
        reviewCount: 10,
        isActive: true,
        createdAt: "2025-11-18",
        updatedAt: "2025-11-18"
    ))
}
