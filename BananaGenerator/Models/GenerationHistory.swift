import Foundation
import UIKit

struct GeneratedImage: Identifiable, Codable {
    let id = UUID()
    let templateName: String
    let originalImageData: Data
    let generatedImageData: Data
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case templateName, originalImageData, generatedImageData, createdAt
    }
    
    var originalImage: UIImage? {
        return UIImage(data: originalImageData)
    }
    
    var generatedImage: UIImage? {
        return UIImage(data: generatedImageData)
    }
    
    init(templateName: String, originalImage: UIImage, generatedImage: UIImage) {
        self.templateName = templateName
        self.originalImageData = originalImage.jpegData(compressionQuality: 0.8) ?? Data()
        self.generatedImageData = generatedImage.jpegData(compressionQuality: 0.8) ?? Data()
        self.createdAt = Date()
    }
}

@Observable
class GenerationHistoryManager {
    static let shared = GenerationHistoryManager()
    
    private(set) var generatedImages: [GeneratedImage] = []
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "GenerationHistory"
    
    init() {
        loadHistory()
    }
    
    func addGeneratedImage(_ image: GeneratedImage) {
        generatedImages.insert(image, at: 0) // Most recent at the front
        saveHistory()
    }
    
    func deleteGeneratedImage(_ image: GeneratedImage) {
        generatedImages.removeAll { $0.id == image.id }
        saveHistory()
    }
    
    func clearHistory() {
        generatedImages.removeAll()
        saveHistory()
    }
    
    var latestImage: GeneratedImage? {
        return generatedImages.first
    }
    
    private func saveHistory() {
        do {
            let encoded = try JSONEncoder().encode(generatedImages)
            userDefaults.set(encoded, forKey: historyKey)
        } catch {
            print("❌ Failed to save history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else { return }
        
        do {
            generatedImages = try JSONDecoder().decode([GeneratedImage].self, from: data)
        } catch {
            print("❌ Failed to load history: \(error)")
            generatedImages = []
        }
    }
}