import XCTest
@testable import Fetch_Recipie

@MainActor
class RecipeListViewModelTests: XCTestCase 
{
    var sut: RecipeListViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        sut = RecipeListViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Fetch Success Tests
    func testFetchRecipes_Success() async {
        // Given
        let mockRecipes = [createValidRecipe()]
        mockNetworkManager.mockResult = .success(mockRecipes)
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertEqual(sut.recipes, mockRecipes)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Empty List Tests
    func testFetchRecipes_EmptyList() async {
        // Given
        mockNetworkManager.mockResult = .success([])
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertEqual(sut.error, .emptyList)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Malformed Data Tests
    func testFetchRecipes_MalformedData() async {
        // Given
        let invalidRecipe = createInvalidRecipe()
        mockNetworkManager.mockResult = .success([invalidRecipe])
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertEqual(sut.error, .malformedData)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Network Error Tests
    func testFetchRecipes_NetworkError() async {
        // Given
        let networkError = NSError(domain: "test", code: -1)
        mockNetworkManager.mockResult = .failure(networkError)
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertEqual(sut.error, .networkError(networkError))
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Loading State Tests
//    func testFetchRecipes_LoadingState() async {
//        // Given
//        mockNetworkManager.mockResult = .success([createValidRecipe()])
//        mockNetworkManager.addDelay = true
//        
//        // When
//        let loadingTask = Task {
//            await sut.fetchRecipes()
//        }
//        
//        // Then - Check loading state
//        XCTAssertTrue(sut.isLoading)
//        
//        await loadingTask.value
//        XCTAssertFalse(sut.isLoading)
//    }
    
    // MARK: - Recipe Validation Tests
    func testValidateRecipe_ValidRecipe() async {
        // Given
        let validRecipe = createValidRecipe()
        mockNetworkManager.mockResult = .success([validRecipe])
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertEqual(sut.recipes.count, 1)
        XCTAssertNil(sut.error)
    }
    
    func testValidateRecipe_InvalidName() async {
        // Given
        var invalidRecipe = createValidRecipe()
        invalidRecipe.name = ""
        mockNetworkManager.mockResult = .success([invalidRecipe])
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertEqual(sut.error, .malformedData)
    }
    
    func testValidateRecipe_InvalidCuisine() async {
        // Given
        var invalidRecipe = createValidRecipe()
        invalidRecipe.cuisine = ""
        mockNetworkManager.mockResult = .success([invalidRecipe])
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertEqual(sut.error, .malformedData)
    }
    
    func testValidateRecipe_NilDifficulty() async {
        // Given
        var invalidRecipe = createValidRecipe()
        invalidRecipe.difficulty = nil
        mockNetworkManager.mockResult = .success([invalidRecipe])
        
        // When
        await sut.fetchRecipes()
        
        // Then
        XCTAssertTrue(sut.recipes.isEmpty)
        XCTAssertEqual(sut.error, .malformedData)
    }
}

// MARK: - Helper Methods
extension RecipeListViewModelTests {
    func createValidRecipe() -> RecipeModel {
        return RecipeModel(
            cuisine: "Italian",
            name: "Pizza",
            photoUrlLarge: "https://example.com/large.jpg",
            photoUrlSmall: "https://example.com/small.jpg",
            uuid: "123",
            sourceUrl: "https://example.com",
            youtubeUrl: "https://youtube.com",
            cookingTime: 30,
            difficulty: "Medium"
        )
    }
    
    func createInvalidRecipe() -> RecipeModel {
        return RecipeModel(
            cuisine: "",
            name: "",
            photoUrlLarge: nil,
            photoUrlSmall: nil,
            uuid: "",
            sourceUrl: nil,
            youtubeUrl: nil,
            cookingTime: nil,
            difficulty: nil
        )
    }
}

// MARK: - Mock Network Manager
class MockNetworkManager: NetworkManager {
    enum MockResult {
        case success([RecipeModel])
        case failure(Error)
    }
    
    var mockResult: MockResult = .success([])
    var addDelay: Bool = false
    
    override func getRecipes() async throws -> [RecipeModel] {
        if addDelay {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        }
        
        switch mockResult {
        case .success(let recipes):
            return recipes
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Equatable Conformance for RecipeError
extension RecipeError: Equatable {
    public static func == (lhs: RecipeError, rhs: RecipeError) -> Bool {
        switch (lhs, rhs) {
        case (.malformedData, .malformedData),
             (.emptyList, .emptyList):
            return true
        case let (.networkError(error1), .networkError(error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}
