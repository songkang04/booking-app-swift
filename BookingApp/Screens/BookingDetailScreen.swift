import SwiftUI

struct BookingDetailScreen: View {
    let bookingId: String

    @State private var booking: Booking?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if let booking = booking {
                bookingDetailContent(booking)
            }
        }
        .background(AppColors.background)
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadBookingDetail()
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(AppColors.primaryBlue)
            Text("Loading booking details...")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                loadBookingDetail()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppColors.primaryBlue)
            .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Booking Detail Content
    private func bookingDetailContent(_ booking: Booking) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Homestay Info Card
                homestayInfoCard(booking)

                // Booking Status Card
                statusCard(booking)

                // Dates Card
                datesCard(booking)

                // Guest & Price Card
                priceCard(booking)
            }
            .padding(16)
        }
    }

    // MARK: - Homestay Info Card
    private func homestayInfoCard(_ booking: Booking) -> some View {
        HStack(spacing: 12) {
            // Image
            AsyncImage(url: URL(string: booking.homestayImage ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(AppColors.textTertiary.opacity(0.3))
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.textTertiary)
                    )
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                Text(booking.homestayName ?? "Homestay")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                if let address = booking.homestayAddress {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.primaryBlue)
                        Text(address)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
    }

    // MARK: - Status Card
    private func statusCard(_ booking: Booking) -> some View {
        VStack(spacing: 12) {
            // Booking ID
            HStack {
                Text("Booking ID")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text(booking.id)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Divider()

            // Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Booking Status")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    Text(booking.statusDisplayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(statusColor(booking.status))
                }
                Spacer()
                statusIcon(booking.status)
            }
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
    }

    // MARK: - Dates Card
    private func datesCard(_ booking: Booking) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Dates")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(booking.numberOfNights) night\(booking.numberOfNights > 1 ? "s" : "")")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }

            HStack(spacing: 12) {
                // Check-in
                VStack(spacing: 4) {
                    Text("Check-in")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                    Text(booking.formattedCheckIn)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.primaryBlue.opacity(0.1))
                .cornerRadius(8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textTertiary)

                // Check-out
                VStack(spacing: 4) {
                    Text("Check-out")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                    Text(booking.formattedCheckOut)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.primaryBlue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
    }

    // MARK: - Price Card
    private func priceCard(_ booking: Booking) -> some View {
        VStack(spacing: 12) {
            // Guest count
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryBlue)
                    Text("Guests")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text("\(booking.guestCount) guest\(booking.guestCount > 1 ? "s" : "")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }

            Divider()

            // Total Price
            HStack {
                Text("Total Price")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(formatPrice(booking.totalPrice))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primaryBlue)
            }
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
    }

    // MARK: - Helper Functions
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "confirmed": return .green
        case "pending": return .orange
        case "cancelled": return .red
        case "completed": return AppColors.primaryBlue
        default: return AppColors.textSecondary
        }
    }

    private func statusIcon(_ status: String) -> some View {
        let iconName: String
        let color: Color

        switch status.lowercased() {
        case "confirmed":
            iconName = "checkmark.circle.fill"
            color = .green
        case "pending":
            iconName = "clock.fill"
            color = .orange
        case "cancelled":
            iconName = "xmark.circle.fill"
            color = .red
        case "completed":
            iconName = "flag.checkered"
            color = AppColors.primaryBlue
        default:
            iconName = "questionmark.circle.fill"
            color = AppColors.textSecondary
        }

        return Image(systemName: iconName)
            .font(.system(size: 32))
            .foregroundColor(color)
    }

    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")₫"
    }

    // MARK: - Load Booking Detail
    private func loadBookingDetail() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let result = try await APIService.shared.getBookingById(id: bookingId)
                await MainActor.run {
                    booking = result
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

