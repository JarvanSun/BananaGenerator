import Foundation
import SwiftUI
import PhotosUI

@Observable
class GenerationViewModel {
    // Core state
    var template: Template? {
        didSet {
            // Update custom prompt when template changes
            if let template = template {
                customPrompt = template.prompt
            }
        }
    }
    var customPrompt: String = ""  // Editable prompt text
    private(set) var selectedImage: UIImage?
    private(set) var generatedImage: UIImage?
    private(set) var isProcessing = false

    // PhotosPicker item with automatic loading
    var selectedItem: PhotosPickerItem? {
        didSet {
            if selectedItem != nil {
                Task {
                    await loadSelectedImage()
                }
            }
        }
    }

    // UI state
    var showOriginal = false
    var showHistory = false
    var showingSaveAlert = false
    var saveAlertMessage = ""

    // Services
    let historyManager = GenerationHistoryManager.shared
    
    // MARK: - Public Methods

    
    func setSelectedImage(_ image: UIImage?) {
        self.selectedImage = image
        self.generatedImage = nil
        self.showOriginal = true // Show the new image
    }
    
    @MainActor
    private func loadSelectedImage() async {
        guard let selectedItem = selectedItem else { return }
        
        do {
            if let data = try await selectedItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.selectedImage = image
                self.generatedImage = nil
                self.showOriginal = true
            }
        } catch {
            // Handle error silently or show alert if needed
        }
    }
    
    func generateImage() {
        // If there's a generated image, use it as the new input for iterative generation
        if let existingGeneratedImage = generatedImage {
            self.selectedImage = existingGeneratedImage
            self.generatedImage = nil
            // Keep showOriginal as false to continue showing the working image
        }

        guard template != nil,
              let image = selectedImage,
              !customPrompt.isEmpty else { return }

        isProcessing = true
        showOriginal = false // Switch to show generated result

        Task {
            do {
                let result = try await GeminiService.shared.generateImage(from: image, using: customPrompt)

                await MainActor.run {
                    self.generatedImage = result
                    self.isProcessing = false

                    // Save to history
                    let generatedImageData = GeneratedImage(
                        templateName: template?.name ?? "Custom",
                        originalImage: image,
                        generatedImage: result
                    )
                    self.historyManager.addGeneratedImage(generatedImageData)

                    // Auto save to photo library
                    UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    // Could show error alert here if needed
                }
            }
        }
    }
    
    func prepareShareItems() -> [Any] {
        guard let image = generatedImage ?? selectedImage else { return [] }
        return [image]
    }

    @MainActor
    func saveImage() {
        guard let image = generatedImage ?? selectedImage else { return }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        saveAlertMessage = "Image saved to photo library"
        showingSaveAlert = true
    }
    
    func clearImages() {
        selectedImage = nil
        generatedImage = nil
        selectedItem = nil
        showOriginal = false
    }

    func reset() {
        template = nil
        clearImages()
    }
    
    var canGenerate: Bool {
        return selectedImage != nil && !isProcessing
    }
}
