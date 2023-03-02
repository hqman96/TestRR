import Foundation

struct SearchResults: Codable {
    let total: Int
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Codable {
    let id: String
    let urls: [PhotoURL.RawValue: String]
    
    enum PhotoURL: String {
        case raw
        case full
        case regular
        case small
        case thumb
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case urls
    }
}

extension UnsplashPhoto: Equatable {
    static func == (lhs: UnsplashPhoto, rhs: UnsplashPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}
