import Foundation

struct Photo: Identifiable, Codable {
    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}

class APIService {
    static let shared = APIService()

    private let baseURL = "http://localhost:3000"
    private let decoder = JSONDecoder()

    func fetchHomestays(limit: Int = 10) async throws -> [Homestay] {
        return try await searchHomestays(limit: limit)
    }

    // MARK: - Search Homestays
    func searchHomestays(
        location: String? = nil,
        minPrice: Int? = nil,
        maxPrice: Int? = nil,
        capacity: Int? = nil,
        page: Int = 1,
        limit: Int = 10
    ) async throws -> [Homestay] {
        var components = URLComponents(string: "\(baseURL)/api/homestays/search")!
        var queryItems: [URLQueryItem] = []

        // Add query parameters
        if let location = location, !location.isEmpty {
            queryItems.append(URLQueryItem(name: "location", value: location))
        }
        if let minPrice = minPrice {
            queryItems.append(URLQueryItem(name: "minPrice", value: String(minPrice)))
        }
        if let maxPrice = maxPrice {
            queryItems.append(URLQueryItem(name: "maxPrice", value: String(maxPrice)))
        }
        if let capacity = capacity {
            queryItems.append(URLQueryItem(name: "capacity", value: String(capacity)))
        }
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))

        components.queryItems = queryItems

        guard let url = components.url else {
            print("❌ [API] Invalid URL")
            throw URLError(.badURL)
        }

        print("🔍 [API] Searching homestays: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("❌ [API] Invalid response type")
                throw URLError(.badServerResponse)
            }

            print("📥 [API] Response status code: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ [API] HTTP Error: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }

            let response = try decoder.decode(HomestayResponse.self, from: data)
            print("✅ [API] Found \(response.data.homestays.count) homestays (total: \(response.data.total))")

            return response.data.homestays
        } catch let error as DecodingError {
            print("❌ [API] Decoding error: \(error)")
            throw error
        } catch {
            print("❌ [API] Request error: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Get Homestay by ID
    func getHomestayById(id: String) async throws -> Homestay {
        let urlString = "\(baseURL)/api/homestays/\(id)"
        print("🔍 [API] Fetching homestay by ID: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ [API] Invalid URL: \(urlString)")
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("❌ [API] Invalid response type")
                throw URLError(.badServerResponse)
            }

            print("📥 [API] Response status code: \(httpResponse.statusCode)")

            // Debug: Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 [API] Raw response: \(jsonString)")
            }

            if httpResponse.statusCode == 404 {
                throw HomestayError.notFound
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ [API] HTTP Error: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }

            let response = try decoder.decode(HomestayDetailResponse.self, from: data)
            print("✅ [API] Fetched homestay: \(response.data.homestay.name)")

            return response.data.homestay
        } catch let error as DecodingError {
            print("❌ [API] Decoding error: \(error)")
            throw error
        } catch {
            print("❌ [API] Request error: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Error Types
enum HomestayError: Error, LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Homestay not found"
        }
    }
}

// MARK: - Response Types
struct HomestayDetailResponse: Codable {
    let success: Bool
    let message: String
    let data: HomestayDetailData
    let timestamp: String
}

struct HomestayDetailData: Codable {
    let homestay: Homestay
}

// MARK: - Booking API Extension
extension APIService {

    // MARK: - Create Booking
    func createBooking(homestayId: String, checkInDate: Date, checkOutDate: Date, guestCount: Int) async throws -> Booking {
        let urlString = "\(baseURL)/api/bookings"
        print("📅 [API] Creating booking: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        // Format dates to ISO8601
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        let requestBody: [String: Any] = [
            "homestayId": homestayId,
            "checkInDate": dateFormatter.string(from: checkInDate),
            "checkOutDate": dateFormatter.string(from: checkOutDate),
            "guestCount": guestCount
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("📥 [API] Response status code: \(httpResponse.statusCode)")

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 [API] Raw response: \(jsonString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
            throw URLError(.badServerResponse)
        }

        let response = try decoder.decode(CreateBookingResponse.self, from: data)
        print("✅ [API] Booking created: \(response.data.id)")

        return response.data
    }

    // MARK: - Verify Booking OTP
    func verifyBookingOTP(bookingId: String, otp: String) async throws {
        let urlString = "\(baseURL)/api/bookings/verify-otp"
        print("🔐 [API] Verifying booking OTP: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let requestBody: [String: Any] = [
            "bookingId": bookingId,
            "otp": otp
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("📥 [API] Response status code: \(httpResponse.statusCode)")

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 [API] Raw response: \(jsonString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
            throw URLError(.badServerResponse)
        }

        print("✅ [API] Booking OTP verified successfully")
    }

    // MARK: - Get User Bookings
    func getUserBookings() async throws -> [Booking] {
        let urlString = "\(baseURL)/api/bookings/user"
        print("📋 [API] Fetching user bookings: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("📥 [API] Response status code: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let response = try decoder.decode(BookingListResponse.self, from: data)
        print("✅ [API] Found \(response.data.bookings.count) bookings")

        return response.data.bookings
    }

    // MARK: - Get Booking Detail
    func getBookingById(id: String) async throws -> Booking {
        let urlString = "\(baseURL)/api/bookings/\(id)"
        print("🔍 [API] Fetching booking: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 [API] Token sent: \(token.prefix(30))...")
        } else {
            print("⚠️ [API] No auth token found!")
        }

        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("📥 [API] Response status code: \(httpResponse.statusCode)")

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 [API] Raw booking detail response: \(jsonString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
            throw URLError(.badServerResponse)
        }

        do {
            let response = try decoder.decode(BookingDetailResponse.self, from: data)
            print("✅ [API] Fetched booking: \(response.data.id)")
            return response.data
        } catch {
            print("❌ [API] Decoding error: \(error)")
            throw error
        }
    }
}

struct HomestayResponse: Codable {
    let success: Bool
    let message: String
    let data: HomestayData
    let timestamp: String
}

struct HomestayData: Codable {
    let homestays: [Homestay]
    let total: Int
    let page: Int
    let limit: Int
    let pages: Int
}
