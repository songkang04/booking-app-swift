import SwiftUI

struct SearchScreen: View {
    @State private var location: String = ""
    @State private var minPrice: String = ""
    @State private var maxPrice: String = ""
    @State private var capacity: String = ""
    @State private var showFilters: Bool = true

    @State private var homestays: [Homestay] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var hasSearched: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Filter Section
                        filterSection

                        // Search Button
                        searchButton

                        // Results Section
                        resultsSection
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
        }
        .background(AppColors.background)
        .onAppear {
            print("🔎 [DEBUG] SearchScreen appeared")
        }
    }

    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Search Filters")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: { withAnimation { showFilters.toggle() } }) {
                    Image(systemName: showFilters ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            .padding(.horizontal, 16)

            if showFilters {
                VStack(spacing: 12) {
                    // Location
                    FilterTextField(
                        icon: "mappin.circle.fill",
                        placeholder: "Location (city, province...)",
                        text: $location
                    )

                    // Price Range
                    HStack(spacing: 12) {
                        FilterTextField(
                            icon: "dollarsign.circle.fill",
                            placeholder: "Min Price",
                            text: $minPrice,
                            keyboardType: .numberPad
                        )

                        FilterTextField(
                            icon: "dollarsign.circle.fill",
                            placeholder: "Max Price",
                            text: $maxPrice,
                            keyboardType: .numberPad
                        )
                    }

                    // Capacity
                    FilterTextField(
                        icon: "person.2.fill",
                        placeholder: "Number of guests",
                        text: $capacity,
                        keyboardType: .numberPad
                    )
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    // MARK: - Search Button
    private var searchButton: some View {
        Button(action: performSearch) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(AppColors.primaryBlue)
            .cornerRadius(10)
        }
        .disabled(isLoading)
        .padding(.horizontal, 16)
    }

    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let error = errorMessage {
                // Error State
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if !hasSearched {
                // Initial State
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textTertiary)
                    Text("Enter filters and tap Search")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if homestays.isEmpty {
                // Empty State
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textTertiary)
                    Text("No homestays found")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("Try adjusting your filters")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Results Header
                Text("\(homestays.count) homestays found")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 16)

                // Results List
                LazyVStack(spacing: 12) {
                    ForEach(homestays) { homestay in
                        NavigationLink(destination: HomestayDetailScreen(homestayId: homestay.id)) {
                            SearchResultCard(homestay: homestay)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Search Action
    private func performSearch() {
        Task {
            isLoading = true
            errorMessage = nil
            hasSearched = true

            do {
                let results = try await APIService.shared.searchHomestays(
                    location: location.isEmpty ? nil : location,
                    minPrice: Int(minPrice),
                    maxPrice: Int(maxPrice),
                    capacity: Int(capacity)
                )

                await MainActor.run {
                    homestays = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Filter TextField Component
struct FilterTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryBlue)
                .font(.system(size: 16))

            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(AppColors.background)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.separator, lineWidth: 1)
        )
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
    let homestay: Homestay

    var body: some View {
        HStack(spacing: 12) {
            // Image
            AsyncImage(url: URL(string: homestay.displayImage)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.secondaryBackground)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.secondaryBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(AppColors.textTertiary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(homestay.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.primaryBlue)
                    Text("\(homestay.city), \(homestay.province)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", homestay.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // Capacity
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .foregroundColor(AppColors.textTertiary)
                            .font(.system(size: 12))
                        Text("\(homestay.capacity)")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                // Price
                Text("\(formatPrice(homestay.price))₫/night")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primaryBlue)
            }

            Spacer()
        }
        .padding(12)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
    }

    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

#Preview {
    SearchScreen()
}
