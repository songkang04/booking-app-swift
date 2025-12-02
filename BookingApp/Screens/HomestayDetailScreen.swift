import SwiftUI

struct HomestayDetailScreen: View {
    let homestayId: String

    @State private var homestay: Homestay?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var currentImageIndex = 0
    @State private var showBookingSheet = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                errorView(error)
            } else if let homestay = homestay {
                detailContent(homestay)
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadHomestay()
        }
    }

    // MARK: - Error View
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Error")
                .font(.system(size: 18, weight: .bold))
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await loadHomestay() }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppColors.primaryBlue)
            .cornerRadius(8)
        }
        .padding()
    }

    // MARK: - Detail Content
    private func detailContent(_ homestay: Homestay) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image Gallery
                imageGallery(homestay)

                VStack(alignment: .leading, spacing: 16) {
                    // Title & Rating
                    titleSection(homestay)

                    Divider()

                    // Location
                    locationSection(homestay)

                    Divider()

                    // Quick Info
                    quickInfoSection(homestay)

                    Divider()

                    // Description
                    descriptionSection(homestay)

                    // Amenities
                    if !homestay.amenities.isEmpty {
                        Divider()
                        amenitiesSection(homestay)
                    }

                    Spacer(minLength: 100)
                }
                .padding(16)
            }
        }
        .overlay(alignment: .bottom) {
            bookingBar(homestay)
        }
    }

    // MARK: - Image Gallery
    private func imageGallery(_ homestay: Homestay) -> some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentImageIndex) {
                ForEach(Array(homestay.images.enumerated()), id: \.offset) { index, imageUrl in
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(AppColors.secondaryBackground)
                                .overlay(ProgressView())
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(AppColors.secondaryBackground)
                                .overlay(Image(systemName: "photo").foregroundColor(AppColors.textTertiary))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 280)

            // Page Indicator
            HStack(spacing: 6) {
                ForEach(0..<homestay.images.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 12)
        }
    }

    // MARK: - Title Section
    private func titleSection(_ homestay: Homestay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(homestay.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", homestay.rating))
                        .font(.system(size: 14, weight: .semibold))
                }
                Text("(\(homestay.reviewCount) reviews)")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Location Section
    private func locationSection(_ homestay: Homestay) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryBlue)
            VStack(alignment: .leading, spacing: 4) {
                Text(homestay.address)
                    .font(.system(size: 14, weight: .medium))
                Text("\(homestay.city), \(homestay.province), \(homestay.country)")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Quick Info Section
    private func quickInfoSection(_ homestay: Homestay) -> some View {
        HStack(spacing: 0) {
            infoItem(icon: "person.2.fill", value: "\(homestay.capacity)", label: "Guests")
            Spacer()
            infoItem(icon: "bed.double.fill", value: "\(homestay.bedroomCount)", label: "Bedrooms")
            Spacer()
            infoItem(icon: "shower.fill", value: "\(homestay.bathroomCount)", label: "Bathrooms")
        }
    }

    private func infoItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryBlue)
            Text(value)
                .font(.system(size: 16, weight: .bold))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Description Section
    private func descriptionSection(_ homestay: Homestay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(size: 16, weight: .bold))
            Text(homestay.description)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Amenities Section
    private func amenitiesSection(_ homestay: Homestay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amenities")
                .font(.system(size: 16, weight: .bold))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(homestay.amenities, id: \.self) { amenity in
                    HStack(spacing: 8) {
                        Image(systemName: amenityIcon(for: amenity))
                            .foregroundColor(AppColors.primaryBlue)
                        Text(amenity)
                            .font(.system(size: 13))
                        Spacer()
                    }
                }
            }
        }
    }

    private func amenityIcon(for amenity: String) -> String {
        let lower = amenity.lowercased()
        if lower.contains("wifi") { return "wifi" }
        if lower.contains("ac") || lower.contains("air") { return "air.conditioner.horizontal" }
        if lower.contains("kitchen") { return "fork.knife" }
        if lower.contains("parking") { return "car.fill" }
        if lower.contains("pool") { return "figure.pool.swim" }
        if lower.contains("tv") { return "tv" }
        return "checkmark.circle.fill"
    }

    // MARK: - Booking Bar
    private func bookingBar(_ homestay: Homestay) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatPrice(homestay.price))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryBlue)
                Text("/ night")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Button(action: { showBookingSheet = true }) {
                Text("Book Now")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryBlue)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.white.shadow(color: Color.black.opacity(0.1), radius: 10, y: -5))
        .sheet(isPresented: $showBookingSheet) {
            BookingScreen(homestay: homestay)
        }
    }

    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(price) VND"
    }

    // MARK: - Load Data
    private func loadHomestay() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await APIService.shared.getHomestayById(id: homestayId)
            await MainActor.run {
                self.homestay = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

