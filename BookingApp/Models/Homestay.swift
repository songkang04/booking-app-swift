import Foundation

struct Homestay: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let address: String
    let city: String
    let province: String
    let country: String
    let images: [String]
    let price: Int
    let capacity: Int
    let bedroomCount: Int
    let bathroomCount: Int
    let amenities: [String]
    let rating: Double
    let reviewCount: Int
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case address
        case city
        case province
        case country
        case images
        case price
        case capacity
        case bedroomCount
        case bathroomCount
        case amenities
        case rating
        case reviewCount
        case isActive
        case createdAt
        case updatedAt
    }
    
    var displayImage: String {
        images.first ?? ""
    }
}
