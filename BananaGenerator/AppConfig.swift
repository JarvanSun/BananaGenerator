import Foundation
import CoreGraphics

struct AppConfig {
    static let appName = "Banana Generator"
    static let version = "0.1.0"
    
    // Mock API mode - when set to true, will skip real API calls and return original image
    static let mockAPIMode = false
    
    // Mock mode configuration
    struct MockMode {
        // Simulated API delay time range (seconds)
        static let minDelay: TimeInterval = 2.0
        static let maxDelay: TimeInterval = 4.0
    }
    
    // Gemini API configuration
    struct GeminiAPI {
        static let apiKey = "YOU_API_KEY_HERE"
        static let model = "gemini-2.5-flash-image-preview"
        static let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    }
    
    // Network and upload parameters
    struct Networking {
        // Request timeout (seconds)
        static let requestTimeout: TimeInterval = 60
        // Whether to fallback to HTTP/2 retry when encountering NSPOSIXErrorDomain code=40 (Message too long)
        static let fallbackHTTP2OnMessageTooLong: Bool = true
    }
    
    // Image preprocessing parameters
    struct ImagePrep {
        // Max dimension for scaling before encoding (pixels)
        static let targetMaxDimension: CGFloat = 1280
        // Maximum JPEG bytes before upload
        static let maxUploadBytes: Int = 4 * 1024 * 1024
        // JPEG initial quality and minimum
        static let jpegQualityInitial: CGFloat = 0.8
        static let jpegQualityMin: CGFloat = 0.45
    }
    
    // Prompt templates
    struct Prompts {
        static let figurinePrompt = """
        create a 1/7 scale commercialized figure of the character in the illustration, in a realistic style and environment. Place the figure on a computer desk, using a circular transparent acrylic base without any text.
        On the computer screen, display the ZBrush modeling process of the figure. Next to the computer screen, place a BANDAI-style toy packaging box printed with the original artwork.
        """
        
        static let sodaScreenPrompt = """
        Transform the character into a vibrant soda advertisement display. Create a modern beverage marketing poster with the character as the main mascot, featuring bright colors, refreshing aesthetics, and commercial appeal suitable for a soft drink brand.
        """
        
        static let idPhotoPrompt = """
        Create a professional ID photo format of the character with a clean white background, proper lighting, and formal presentation suitable for official documents. Maintain clear facial features and professional appearance.
        """
        
        static let portraitPrompt = """
        Generate an artistic portrait of the character with professional photography styling, emphasizing character features and personality. Use studio lighting and composition techniques for an appealing personal portrait.
        """
        
        static let dollPrompt = """
        Transform the character into a cute plush toy or doll version, with soft fabric textures, rounded features, and adorable styling suitable for a collectible stuffed toy product.
        """
    }
}
