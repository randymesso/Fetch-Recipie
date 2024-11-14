import UIKit

//Custom protocol for the NetworkManager
protocol URLSessionProtocolNetworkManager
{
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}
extension URLSession: URLSessionProtocolNetworkManager { }

class NetworkManager
{
    static let shared = NetworkManager()
    var urlEndPoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"  //Good Data
    private let session: URLSessionProtocolNetworkManager
    
    init(session: URLSessionProtocolNetworkManager = URLSession.shared) 
    {
        self.session = session
    }
    
    func getRecipes() async throws -> [RecipeModel] 
    {
        guard let url = URL(string: urlEndPoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url, delegate: nil)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode 
        {
        case 200...299:
            do 
            {
                // Decode the response wrapper first
                let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                
                // Now modify the recipes with your additional data
                var recipes = recipeResponse.recipes
                
                //Adding custom data to help with UX
                recipes = recipes.map { recipe in
                    var mutableRecipe = recipe
                    mutableRecipe.cookingTime = Int.random(in: 3...12) * 5
                    mutableRecipe.difficulty = ["Easy", "Medium", "Hard"].randomElement()
                    return mutableRecipe
                }
                
                return recipes
            } 
            catch
            {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.custom("Unauthorized")
        case 403:
            throw NetworkError.custom("Forbidden")
        case 404:
            throw NetworkError.custom("Resource not found")
        default:
            throw NetworkError.custom("Server error: \(httpResponse.statusCode)")
        }
    }
}
