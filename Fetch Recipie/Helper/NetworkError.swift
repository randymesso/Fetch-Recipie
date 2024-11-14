import Foundation


// MARK: - Network Errors
enum NetworkError: LocalizedError 
{
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case custom(String)
    case invalidResponse
    case invalidData
    
    var errorDescription: String? 
    {
        switch self 
        {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .invalidResponse:
            return "Invalid response from network"
        case .invalidData:
            return "Invalid data"
        case .custom(let message):
            return message
        }
    }
}
