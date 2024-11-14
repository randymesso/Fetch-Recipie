import UIKit

//Custom protocol for the Image Loader
protocol URLSessionProtocolImageLoader
{
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocolImageLoader { }

// Image error types
enum ImageLoadingError: Error {
    case invalidURL
    case invalidData
    case networkError
}

// Add the ImageLoader class
final class ImageLoader
{
    static let shared = ImageLoader()
    private let session: URLSessionProtocolImageLoader
    
    init(session: URLSessionProtocolImageLoader = URLSession.shared) {
        self.session = session
        try? fileManager.createDirectory(at: cacheDirectory,withIntermediateDirectories: true)
    }
    
    // Memory cache for quick access
    let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    // Disk cache directory
    var cacheDirectory: URL
    {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache")
    }
    
    func loadImage(from urlString: String) async throws -> UIImage
    {
        // Check memory cache first
        if let cachedImage = cache.object(forKey: urlString as NSString)
        {
            return cachedImage
        }
        
        // Check disk cache
        let fileName = urlString.hash.description
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // Store in memory cache for faster future access
            cache.setObject(image, forKey: urlString as NSString)
            return image
        }
        
        // Load from network if not cached
        guard let url = URL(string: urlString) else {
            throw ImageLoadingError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageLoadingError.networkError
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageLoadingError.invalidData
        }
        
        // Store in both memory and disk cache
        cache.setObject(image, forKey: urlString as NSString)
        try? data.write(to: fileURL)
        
        return image
    }
    
    func clearMemoryCache()
    {
        cache.removeAllObjects()
    }
    
    func clearDiskCache()
    {
        // Remove disk cache directory and recreate it
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func clearAllCache()
    {
        clearMemoryCache()
        clearDiskCache()
    }
    
    func clearOldCache(olderThan days: Int = 7)
    {
        let oldDate = Date().addingTimeInterval(-TimeInterval(days * 24 * 60 * 60))
        
        guard let contents = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.creationDateKey]
        ) else { return }
        
        for fileURL in contents
        {
            guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                  let creationDate = attributes[.creationDate] as? Date,
                  creationDate < oldDate else { continue }
            
            try? fileManager.removeItem(at: fileURL)
        }
    }
}


