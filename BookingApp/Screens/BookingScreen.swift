import SwiftUI

struct BookingScreen: View {
    let homestay: Homestay
    @Environment(\.dismiss) private var dismiss

    @State private var checkInDate = Date()
    @State private var checkOutDate = Date().addingTimeInterval(86400) // Tomorrow
    @State private var guestCount = 1
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showOTPVerification = false
    @State private var createdBooking: Booking?

    private var numberOfNights: Int {
        let days = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 1
        return max(days, 1)
    }

    private var totalPrice: Int {
        homestay.price * numberOfNights
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Homestay Summary
                    homestayCard

                    // Date Selection
                    dateSection

                    // Guest Count
                    guestSection

                    // Price Summary
                    priceSummary

                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // Book Button
                    bookButton
                }
                .padding(.vertical, 16)
            }
            .background(AppColors.background)
            .navigationTitle("Book Homestay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationDestination(isPresented: $showOTPVerification) {
                if let booking = createdBooking {
                    BookingOTPVerificationView(booking: booking) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Homestay Card
    private var homestayCard: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: homestay.displayImage)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(AppColors.secondaryBackground)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(homestay.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                Text("\(homestay.city), \(homestay.province)")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)

                Text("\(formatPrice(homestay.price))₫/night")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primaryBlue)
            }
            Spacer()
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    // MARK: - Date Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Dates")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check-in")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    DatePicker("", selection: $checkInDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: checkInDate) { _, newValue in
                            if checkOutDate <= newValue {
                                checkOutDate = newValue.addingTimeInterval(86400)
                            }
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Check-out")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    DatePicker("", selection: $checkOutDate, in: checkInDate.addingTimeInterval(86400)..., displayedComponents: .date)
                        .labelsHidden()
                }
            }
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    // MARK: - Guest Section
    private var guestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Guests")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack {
                Text("\(guestCount) guest\(guestCount > 1 ? "s" : "")")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Stepper("", value: $guestCount, in: 1...homestay.capacity)
                    .labelsHidden()
            }

            Text("Maximum \(homestay.capacity) guests")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    // MARK: - Price Summary
    private var priceSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(formatPrice(homestay.price))₫ × \(numberOfNights) night\(numberOfNights > 1 ? "s" : "")")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text("\(formatPrice(totalPrice))₫")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textPrimary)
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(formatPrice(totalPrice))₫")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primaryBlue)
            }
        }
        .padding(16)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    // MARK: - Book Button
    private var bookButton: some View {
        Button(action: createBooking) {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Confirm Booking")
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primaryBlue)
            .cornerRadius(12)
        }
        .disabled(isLoading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Actions
    private func createBooking() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                let booking = try await APIService.shared.createBooking(
                    homestayId: homestay.id,
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                    guestCount: guestCount
                )

                await MainActor.run {
                    createdBooking = booking
                    isLoading = false
                    showOTPVerification = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

