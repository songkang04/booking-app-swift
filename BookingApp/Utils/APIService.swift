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
        let urlString = "\(baseURL)/api/homestays/search"
        print("🔍 [API] Fetching homestays from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ [API] Invalid URL: \(urlString)")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📤 [API] Sending request with method: \(request.httpMethod ?? "GET")")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("❌ [API] Invalid response type")
                throw URLError(.badServerResponse)
            }
            
            print("📥 [API] Response status code: \(httpResponse.statusCode)")
            
            // Log raw response data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📊 [API] Raw response data: \(jsonString.prefix(500))...")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ [API] HTTP Error: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
            
            let response = try decoder.decode(HomestayResponse.self, from: data)
            print("✅ [API] Successfully decoded response: \(response.data.homestays.count) homestays")
            
            // Log each homestay
            response.data.homestays.forEach { homestay in
                print("  📍 \(homestay.name) - Images: \(homestay.images.count)")
            }
            
            return response.data.homestays
        } catch let error as DecodingError {
            print("❌ [API] Decoding error: \(error)")
            throw error
        } catch {
            print("❌ [API] Request error: \(error.localizedDescription)")
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
