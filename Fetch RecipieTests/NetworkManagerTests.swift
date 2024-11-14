import XCTest
@testable import Fetch_Recipie

class NetworkManagerTests: XCTestCase {
    var sut: NetworkManager!
    var mockURLSession: MockURLSessionNetworkManager!
    //var mockSession: MockURLSessionNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSessionNetworkManager()
        sut = NetworkManager(session: mockURLSession)
    }
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - URL Tests
    func testInvalidURL() async 
    {
        // Given
        let networkManager = NetworkManager()
        networkManager.urlEndPoint = "" 
        
        // When/Then
        do 
        {
            _ = try await networkManager.getRecipes()
            XCTFail("Should throw invalid URL error")
        } 
        catch
        {
            XCTAssertEqual(error as? NetworkError, .invalidURL)
        }
    }
    
    // MARK: - Success Cases
    func testGetRecipes_Success() async throws {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let mockData = createMockRecipeData()
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        
        // When
        let recipes = try await sut.getRecipes()
        
        // Then
        XCTAssertFalse(recipes.isEmpty)
        XCTAssertNotNil(recipes.first?.cookingTime)
        XCTAssertNotNil(recipes.first?.difficulty)
    }
    
    // MARK: - Error Cases
    func testGetRecipes_InvalidResponse() async {
        // Given
        mockURLSession.mockResponse = URLResponse() // Not HTTPURLResponse
        
        // When/Then
        do {
            _ = try await sut.getRecipes()
            XCTFail("Should throw invalid response error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }
    
    func testGetRecipes_DecodingError() async {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        mockURLSession.mockData = "Invalid JSON".data(using: .utf8)
        mockURLSession.mockResponse = mockResponse
        
        // When/Then
        do {
            _ = try await sut.getRecipes()
            XCTFail("Should throw decoding error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .decodingError)
        }
    }
    
    // MARK: - HTTP Status Code Tests
    func testGetRecipes_Unauthorized() async {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        mockURLSession.mockResponse = mockResponse
        
        // When/Then
        do {
            _ = try await sut.getRecipes()
            XCTFail("Should throw unauthorized error")
        } catch let NetworkError.custom(message) {
            XCTAssertEqual(message, "Unauthorized")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetRecipes_Forbidden() async {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil
        )
        mockURLSession.mockResponse = mockResponse
        
        // When/Then
        do {
            _ = try await sut.getRecipes()
            XCTFail("Should throw forbidden error")
        } catch let NetworkError.custom(message) {
            XCTAssertEqual(message, "Forbidden")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Data Modification Tests
    func testRecipeModification() async throws {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let mockData = createMockRecipeData()
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        
        // When
        let recipes = try await sut.getRecipes()
        
        // Then
        XCTAssertTrue(recipes.allSatisfy { $0.cookingTime != nil })
        XCTAssertTrue(recipes.allSatisfy { $0.difficulty != nil })
        
        if let cookingTime = recipes.first?.cookingTime {
            XCTAssertTrue((15...60).contains(cookingTime))
            XCTAssertTrue(cookingTime % 5 == 0)
        }
        
        if let difficulty = recipes.first?.difficulty {
            XCTAssertTrue(["Easy", "Medium", "Hard"].contains(difficulty))
        }
    }
}

// MARK: - Helper Methods
extension NetworkManagerTests {
    func createMockRecipeData() -> Data {
        let recipe = RecipeResponse(recipes: [
            RecipeModel(
                cuisine: "Italian",
                name: "Pizza",
                photoUrlLarge: "https://example.com/large.jpg",
                photoUrlSmall: "https://example.com/small.jpg",
                uuid: "123",
                sourceUrl: "https://example.com",
                youtubeUrl: "https://youtube.com",
                cookingTime: nil,
                difficulty: nil
            )
        ])
        
        return try! JSONEncoder().encode(recipe)
    }
}

// MARK: - Mock Classes
class MockURLSessionNetworkManager: URLSessionProtocolNetworkManager
{
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return (mockData ?? Data(), mockResponse ?? URLResponse())
    }
}

// MARK: - NetworkError Equatable
extension NetworkError: Equatable 
{
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError):
            return true
        case let (.custom(message1), .custom(message2)):
            return message1 == message2
        default:
            return false
        }
    }
}
