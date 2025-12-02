import Foundation

// MARK: - Embedded User Info (for populated responses)
struct BookingUserInfo: Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case email
    }
}

// MARK: - Embedded Homestay Info (for populated responses)
struct BookingHomestayInfo: Codable {
    let id: String
    let name: String?
    let address: String?
    let images: [String]?
    let price: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case address
        case images
        case price
    }
}

// MARK: - Flexible ID that can be String or Object
enum FlexibleId: Codable {
    case string(String)
    case userInfo(BookingUserInfo)
    case homestayInfo(BookingHomestayInfo)

    var stringValue: String {
        switch self {
        case .string(let id):
            return id
        case .userInfo(let info):
            return info.id
        case .homestayInfo(let info):
            return info.id
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Try to decode as string first
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
            return
        }

        // Try to decode as homestay info
        if let homestayInfo = try? container.decode(BookingHomestayInfo.self) {
            self = .homestayInfo(homestayInfo)
            return
        }

        // Try to decode as user info
        if let userInfo = try? container.decode(BookingUserInfo.self) {
            self = .userInfo(userInfo)
            return
        }

        throw DecodingError.typeMismatch(FlexibleId.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or Object"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let id):
            try container.encode(id)
        case .userInfo(let info):
            try container.encode(info)
        case .homestayInfo(let info):
            try container.encode(info)
        }
    }
}

struct Booking: Identifiable, Codable {
    let id: String
    let homestayIdValue: FlexibleId
    let userIdValue: FlexibleId
    let checkInDate: String
    let checkOutDate: String
    let totalPrice: Int
    let status: String
    let guestCount: Int
    let createdAt: String
    let updatedAt: String

    // Computed properties for compatibility
    var homestayId: String { homestayIdValue.stringValue }
    var userId: String { userIdValue.stringValue }

    // Populated homestay info
    var homestayName: String? {
        if case .homestayInfo(let info) = homestayIdValue {
            return info.name
        }
        return nil
    }

    var homestayImage: String? {
        if case .homestayInfo(let info) = homestayIdValue {
            return info.images?.first
        }
        return nil
    }

    var homestayAddress: String? {
        if case .homestayInfo(let info) = homestayIdValue {
            return info.address
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case homestayId
        case homestay  // Alternative key name
        case userId
        case user  // Alternative key name
        case checkInDate
        case checkOutDate
        case totalPrice
        case status
        case guestCount
        case numberOfGuests  // Alternative key name
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        checkInDate = try container.decode(String.self, forKey: .checkInDate)
        checkOutDate = try container.decode(String.self, forKey: .checkOutDate)
        totalPrice = try container.decode(Int.self, forKey: .totalPrice)
        status = try container.decode(String.self, forKey: .status)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)

        // Try guestCount first, then numberOfGuests
        if let guests = try? container.decode(Int.self, forKey: .guestCount) {
            guestCount = guests
        } else if let guests = try? container.decode(Int.self, forKey: .numberOfGuests) {
            guestCount = guests
        } else {
            guestCount = 1
        }

        // Try homestayId first, then homestay
        if let value = try? container.decode(FlexibleId.self, forKey: .homestayId) {
            homestayIdValue = value
        } else if let value = try? container.decode(FlexibleId.self, forKey: .homestay) {
            homestayIdValue = value
        } else {
            throw DecodingError.keyNotFound(CodingKeys.homestayId, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Neither homestayId nor homestay found"))
        }

        // Try userId first, then user
        if let value = try? container.decode(FlexibleId.self, forKey: .userId) {
            userIdValue = value
        } else if let value = try? container.decode(FlexibleId.self, forKey: .user) {
            userIdValue = value
        } else {
            throw DecodingError.keyNotFound(CodingKeys.userId, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Neither userId nor user found"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(homestayIdValue, forKey: .homestayId)
        try container.encode(userIdValue, forKey: .userId)
        try container.encode(checkInDate, forKey: .checkInDate)
        try container.encode(checkOutDate, forKey: .checkOutDate)
        try container.encode(totalPrice, forKey: .totalPrice)
        try container.encode(status, forKey: .status)
        try container.encode(guestCount, forKey: .guestCount)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    // Computed property for formatted dates
    var formattedCheckIn: String {
        formatDate(checkInDate)
    }

    var formattedCheckOut: String {
        formatDate(checkOutDate)
    }

    var numberOfNights: Int {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let checkIn = formatter.date(from: checkInDate),
              let checkOut = formatter.date(from: checkOutDate) else {
            return 1
        }

        let days = Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1
        return max(days, 1)
    }

    var statusDisplayName: String {
        switch status.lowercased() {
        case "pending":
            return "Pending"
        case "confirmed":
            return "Confirmed"
        case "cancelled":
            return "Cancelled"
        case "completed":
            return "Completed"
        default:
            return status.capitalized
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd/MM/yyyy"
        return displayFormatter.string(from: date)
    }
}

// MARK: - Booking Request
struct CreateBookingRequest: Codable {
    let homestayId: String
    let checkInDate: String
    let checkOutDate: String
    let guestCount: Int
}

struct VerifyBookingOTPRequest: Codable {
    let bookingId: String
    let otp: String
}

// MARK: - Booking Responses
struct CreateBookingResponse: Codable {
    let success: Bool
    let message: String
    let data: CreateBookingData
    let timestamp: String
}

// CreateBookingData is now just an alias for Booking since API returns booking data directly
typealias CreateBookingData = Booking

struct BookingListResponse: Codable {
    let success: Bool
    let message: String
    let data: BookingListData
    let timestamp: String
}

struct BookingListData: Codable {
    let bookings: [Booking]
}

struct BookingDetailResponse: Codable {
    let success: Bool
    let message: String
    let data: Booking  // Booking is directly in data, not data.booking
    let timestamp: String
}

struct VerifyBookingOTPResponse: Codable {
    let success: Bool
    let message: String
    let timestamp: String
}

