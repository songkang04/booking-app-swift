import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    func fetchPhotos(limit: Int = 10) async throws -> [Photo] {
        guard let url = URL(string: "\(baseURL)/photos?_limit=\(limit)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let photos = try JSONDecoder().decode([Photo].self, from: data)
        return photos
    }
}
