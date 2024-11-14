import UIKit
import SwiftUI

enum RecipeError: Error {
    case malformedData
    case emptyList
    case networkError(Error)
}

@MainActor
class RecipeListViewModel 
{
    @Published var recipes: [RecipeModel] = []
    @Published var error: RecipeError?
    @Published private(set) var isLoading = false
    
    private let networkManager: NetworkManager
    
    nonisolated init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func fetchRecipes() async
    {
        isLoading = true
        error = nil
        
        do 
        {
            let fetchedRecipes = try await networkManager.getRecipes()
            
            // Check for empty list
            guard !fetchedRecipes.isEmpty else {
                error = .emptyList
                recipes = []
                isLoading = false
                return
            }
            
            // Validate recipes
            guard fetchedRecipes.allSatisfy({ validateRecipe($0) }) else {
                error = .malformedData
                recipes = []
                isLoading = false
                return
            }
            
            recipes = fetchedRecipes
        } 
        catch
        {
            self.error = .networkError(error)
            recipes = []
        }
        
        isLoading = false
    }
    
    private func validateRecipe(_ recipe: RecipeModel) -> Bool 
    {
        return !recipe.name.isEmpty &&
               !recipe.cuisine.isEmpty &&
               recipe.difficulty != nil
    }
}
