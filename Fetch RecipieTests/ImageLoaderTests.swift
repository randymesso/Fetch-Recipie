import XCTest
@testable import Fetch_Recipie

class ImageLoaderTests: XCTestCase {
    var sut: ImageLoader!
    var mockFileManager: MockFileManager!
    var mockURLSession: MockURLSessionImageLoader!
    
    override func setUp() 
    {
        super.setUp()
        mockFileManager = MockFileManager()
        mockURLSession = MockURLSessionImageLoader()
        sut = ImageLoader(session: mockURLSession)
    }
    
    override func tearDown() {
        sut.clearAllCache()
        sut = nil
        mockFileManager = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInit_CreatesCacheDirectory() {
        // Given
        let cacheDirectory = sut.cacheDirectory
        
        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: cacheDirectory.path))
    }
    
    // MARK: - Memory Cache Tests
    func testLoadImage_MemoryCacheHit_ReturnsImageFromCache() async throws {
        // Given
        let urlString = "https://example.com/image.jpg"
        let testImage = UIImage()
        sut.cache.setObject(testImage, forKey: urlString as NSString)
        
        // When
        let result = try await sut.loadImage(from: urlString)
        
        // Then
        XCTAssertEqual(result, testImage)
    }
    
    func testClearMemoryCache_RemovesAllObjects() {
        // Given
        let testImage = UIImage()
        sut.cache.setObject(testImage, forKey: "test" as NSString)
        
        // When
        sut.clearMemoryCache()
        
        // Then
        XCTAssertNil(sut.cache.object(forKey: "test" as NSString))
    }
    
    // MARK: - Disk Cache Tests
    func testLoadImage_DiskCacheHit_ReturnsImageFromDisk() async throws {
        // Given
        let urlString = "https://example.com/image.jpg"
        let testImage = UIImage(systemName: "star")!
        let data = testImage.pngData()!
        let fileURL = sut.cacheDirectory.appendingPathComponent(urlString.hash.description)
        try? data.write(to: fileURL)
        
        // When
        let result = try await sut.loadImage(from: urlString)
        
        // Then
        XCTAssertNotNil(result)
        // Note: Can't directly compare UIImages, so check if it exists
    }
    
    func testClearDiskCache_RemovesAllFiles() {
        // Given
        let fileURL = sut.cacheDirectory.appendingPathComponent("test")
        try? "test".write(to: fileURL, atomically: true, encoding: .utf8)
        
        // When
        sut.clearDiskCache()
        
        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    // MARK: - Network Loading Tests
    func testLoadImage_NetworkSuccess_SavesToCaches() async throws {
        // Given
        let urlString = "https://example.com/image.jpg"
        let testImage = UIImage(systemName: "star")!
        let imageData = testImage.pngData()!
        mockURLSession.mockData = imageData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: urlString)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let result = try await sut.loadImage(from: urlString)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(sut.cache.object(forKey: urlString as NSString))
        let fileURL = sut.cacheDirectory.appendingPathComponent(urlString.hash.description)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    func testLoadImage_InvalidURL_ThrowsError() async {
        // Given
        let invalidURL = ""
        
        // When/Then
        do {
            _ = try await sut.loadImage(from: invalidURL)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? ImageLoadingError, .invalidURL)
        }
    }
    
//    func testLoadImage_NetworkError_ThrowsError() async {
//        // Given
//        let urlString = "https://example.com/image.jpg"
//        mockURLSession.mockError = NSError(domain: "", code: -1)
//        
//        // When/Then
//        do {
//            _ = try await sut.loadImage(from: urlString)
//            XCTFail("Should throw error")
//        } catch {
//            XCTAssertEqual(error as? ImageLoadingError, .networkError)
//        }
//    }
    
    // MARK: - Cache Cleanup Tests
    func testClearOldCache_RemovesOldFiles() {
        // Given
        let oldFileURL = sut.cacheDirectory.appendingPathComponent("old")
        let newFileURL = sut.cacheDirectory.appendingPathComponent("new")
        
        try? "old".write(to: oldFileURL, atomically: true, encoding: .utf8)
        try? "new".write(to: newFileURL, atomically: true, encoding: .utf8)
        
        // Modify creation date for old file
        let oldDate = Date().addingTimeInterval(-8 * 24 * 60 * 60) // 8 days old
        try? FileManager.default.setAttributes(
            [.creationDate: oldDate],
            ofItemAtPath: oldFileURL.path
        )
        
        // When
        sut.clearOldCache(olderThan: 7)
        
        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldFileURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFileURL.path))
    }
}

// MARK: - Mock Classes
class MockFileManager: FileManager {
    var createDirectoryCalled = false
    var removeItemCalled = false
    
    override func createDirectory(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        createDirectoryCalled = true
    }
    
    override func removeItem(at URL: URL) throws {
        removeItemCalled = true
    }
}

class MockURLSessionImageLoader: URLSessionProtocolImageLoader {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return (mockData ?? Data(),mockResponse ?? URLResponse()
        )
    }
}

// MARK: - Helper Extensions
extension ImageLoadingError: Equatable {
    static func == (lhs: ImageLoadingError, rhs: ImageLoadingError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidData, .invalidData),
             (.networkError, .networkError):
            return true
        default:
            return false
        }
    }
}
