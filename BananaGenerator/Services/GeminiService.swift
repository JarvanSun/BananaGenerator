import Foundation
import UIKit

enum GeminiError: LocalizedError {
    case invalidAPIKey
    case invalidURL
    case invalidResponse
    case networkError(String)
    case apiError(String)
    case noImageGenerated
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key"
        case .invalidURL:
            return "Invalid request URL"
        case .invalidResponse:
            return "Invalid response format"
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .noImageGenerated:
            return "No image generated"
        }
    }
}

class GeminiService {
    static let shared = GeminiService()
    
    private init() {}
    
    func generateImage(from image: UIImage, using prompt: String) async throws -> UIImage {
        // Mock mode: skip API call, return original image
        if AppConfig.mockAPIMode {
            print("[MOCK MODE] Skipping real API call")
            print("[MOCK MODE] Prompt: \(prompt.prefix(50))...")
            
            // Generate random delay time
            let delay = TimeInterval.random(
                in: AppConfig.MockMode.minDelay...AppConfig.MockMode.maxDelay
            )
            print("[MOCK MODE] Simulated delay: \(String(format: "%.1f", delay)) seconds")
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            print("[MOCK MODE] Returning original image")
            return image
        }
        
        // Validate API key
        guard !AppConfig.GeminiAPI.apiKey.isEmpty else {
            throw GeminiError.invalidAPIKey
        }
        
        print("Starting image generation... Prompt: \(prompt.prefix(50))...")
        
        // Compress/scale image and convert to base64 (control size, improve reliability)
        guard let prep = Self.prepareBase64JPEG(from: image) else {
            throw GeminiError.invalidResponse
        }
        let base64Image = prep.base64
        #if DEBUG
        print("Input image size: \(prep.originalSize.width)x\(prep.originalSize.height), encoded size: \(prep.encodedSize.width)x\(prep.encodedSize.height), JPEG: \(prep.byteCount) bytes, base64: ~\(base64Image.count) chars")
        #endif
        
        // Build request URL
        guard let url = URL(string: "\(AppConfig.GeminiAPI.baseURL)/models/\(AppConfig.GeminiAPI.model):generateContent?key=\(AppConfig.GeminiAPI.apiKey)") else {
            throw GeminiError.invalidURL
        }
        
        // Build request body - single step generation
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        [
                            "inlineData": [  // Note: using camelCase naming
                                "mimeType": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.8,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 8192,
                "responseModalities": ["IMAGE", "TEXT"]  // Support both response types
            ],
            "safetySettings": [
                [
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_LOW_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_LOW_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_LOW_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_LOW_AND_ABOVE"
                ]
            ]
        ]
        
        // Send request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = AppConfig.Networking.requestTimeout
        #if DEBUG
        print("Request body size: \(request.httpBody?.count ?? 0) bytes")
        #endif
        
        let (data, response) = try await Self.send(request: request)
        
        // Debug output
        if let jsonString = String(data: data, encoding: .utf8) {
            #if DEBUG
            print("API response: \(jsonString.prefix(500))...")
            #endif
        }
        
        // Check response status
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                print("❌ API request failed - status code: \(httpResponse.statusCode)")
                if let errorMessage = String(data: data, encoding: .utf8) {
                    print("❌ Error message: \(errorMessage)")
                }
                throw GeminiError.apiError("Status code: \(httpResponse.statusCode)")
            }
        }
        
        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            throw GeminiError.invalidResponse
        }
        
        // Iterate through parts to find image data (using correct camelCase naming)
        for part in parts {
            // Note: API returns camelCase naming for inlineData and mimeType
            if let inlineData = part["inlineData"] as? [String: Any],
               let mimeType = inlineData["mimeType"] as? String,
               mimeType.hasPrefix("image/"),
               let imageDataString = inlineData["data"] as? String,
               let imageData = Data(base64Encoded: imageDataString),
               let generatedImage = UIImage(data: imageData) {
                print("✅ Successfully generated image!")
                return generatedImage
            }
        }
        
        throw GeminiError.noImageGenerated
    }

    // MARK: - Networking helpers
    private static func send(request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch let error as NSError {
            print("⚠️ Request failed (first attempt): \(error.domain) code=\(error.code)")
            // Common: NSPOSIXErrorDomain code=40 (Message too long), often occurs in HTTP/3/UDP transport
            if AppConfig.Networking.fallbackHTTP2OnMessageTooLong &&
               error.domain == NSPOSIXErrorDomain && error.code == 40 {
                print("Triggering HTTP/2 fallback (disabling Alt-Svc / HTTP/3), retrying...")
                let config = URLSessionConfiguration.default
                config.httpAdditionalHeaders = ["Alt-Svc": "clear"]
                config.waitsForConnectivity = true
                let session = URLSession(configuration: config)
                return try await session.data(for: request)
            }
            throw error
        }
    }
    
    // MARK: - Image prep helpers
    private static func prepareBase64JPEG(from image: UIImage) -> (base64: String, byteCount: Int, originalSize: CGSize, encodedSize: CGSize)? {
        let originalSize = image.size
        let targetMax: CGFloat = AppConfig.ImagePrep.targetMaxDimension
        let encodedImage = image.resized(maxDimension: targetMax)
        var quality: CGFloat = AppConfig.ImagePrep.jpegQualityInitial
        let maxBytes = AppConfig.ImagePrep.maxUploadBytes
        var data = encodedImage.jpegData(compressionQuality: quality)
        while let d = data, d.count > maxBytes, quality > AppConfig.ImagePrep.jpegQualityMin {
            quality -= 0.1
            data = encodedImage.jpegData(compressionQuality: quality)
        }
        guard let final = data else { return nil }
        let base64 = final.base64EncodedString()
        return (base64, final.count, originalSize, encodedImage.size)
    }
}

// MARK: - UIImage utilities
private extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let w = size.width, h = size.height
        let maxSide = max(w, h)
        guard maxSide > maxDimension else { return self }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: floor(w * scale), height: floor(h * scale))
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1 // Pixel size already controlled, no longer depends on screen scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
