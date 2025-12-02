import SwiftUI

struct BookingsListScreen: View {
    @State private var bookings: [Booking] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        NavigationStack {
            Group {
                if !authManager.isLoggedIn {
                    notLoggedInView
                } else if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else if bookings.isEmpty {
                    emptyView
                } else {
                    bookingsList
                }
            }
            .background(AppColors.background)
            .navigationTitle("My Bookings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if authManager.isLoggedIn {
                loadBookings()
            }
        }
    }

    // MARK: - Not Logged In View
    private var notLoggedInView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)

            Text("Please log in to view your bookings")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(AppColors.primaryBlue)
            Text("Loading bookings...")
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
                loadBookings()
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

    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)

            Text("No Bookings Yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            Text("Your booking history will appear here")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bookings List
    private var bookingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(bookings) { booking in
                    NavigationLink(destination: BookingDetailScreen(bookingId: booking.id)) {
                        BookingCard(booking: booking)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
        }
    }

    // MARK: - Load Bookings
    private func loadBookings() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                let result = try await APIService.shared.getUserBookings()
                await MainActor.run {
                    bookings = result
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

// MARK: - Booking Card
struct BookingCard: View {
    let booking: Booking

    var statusColor: Color {
        switch booking.status.lowercased() {
        case "confirmed": return .green
        case "pending": return .orange
        case "cancelled": return .red
        case "completed": return AppColors.primaryBlue
        default: return AppColors.textSecondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with status
            HStack {
                Text(booking.homestayName ?? "Homestay")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Spacer()

                Text(booking.statusDisplayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(6)
            }

            // Dates
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.primaryBlue)
                    Text(booking.formattedCheckIn)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textTertiary)

                Text(booking.formattedCheckOut)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }

            Divider()

            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                    Text("\(booking.guestCount) guest\(booking.guestCount > 1 ? "s" : "")")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Text("\(formatPrice(booking.totalPrice))₫")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.primaryBlue)
            }
        }
        .padding(16)
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
