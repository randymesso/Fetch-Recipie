import XCTest
@testable import Fetch_Recipie

class NetworkErrorTests: XCTestCase 
{
    
    func testInvalidURL_ErrorDescription() {
        // Given
        let error = NetworkError.invalidURL
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Invalid URL")
    }
    
    func testNoData_ErrorDescription() {
        // Given
        let error = NetworkError.noData
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "No data received")
    }
    
    func testDecodingError_ErrorDescription() {
        // Given
        let error = NetworkError.decodingError
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Failed to decode response")
    }
    
    func testServerError_ErrorDescription() {
        // Given
        let error = NetworkError.serverError(404)
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Server error: 404")
    }
    
    func testInvalidResponse_ErrorDescription() {
        // Given
        let error = NetworkError.invalidResponse
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Invalid response from network")
    }
    
    func testInvalidData_ErrorDescription() {
        // Given
        let error = NetworkError.invalidData
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Invalid data")
    }
    
    func testCustomError_ErrorDescription() {
        // Given
        let customMessage = "Custom error message"
        let error = NetworkError.custom(customMessage)
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, customMessage)
    }
}
