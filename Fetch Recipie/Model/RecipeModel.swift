import UIKit

// Root response model
struct RecipeResponse: Codable 
{
    let recipes: [RecipeModel]
}

struct RecipeModel: Codable, Equatable
{
    // Properties from JSON
    var cuisine: String
    var name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let uuid: String
    let sourceUrl: String?
    let youtubeUrl: String?
    
    // Additional properties not in JSON
    var cookingTime: Int?
    var difficulty: String?
    
    
    //Bypass Snake Case - Camel Case
    enum CodingKeys: String, CodingKey
    {
        case cuisine
        case name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case uuid
        case sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }
}
