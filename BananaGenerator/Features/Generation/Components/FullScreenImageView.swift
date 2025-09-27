import SwiftUI

/// Full-screen image view with toggle switch overlay
struct FullScreenImageView: View {
    let selectedImage: UIImage?
    let generatedImage: UIImage?
    let templateImage: UIImage?
    let isProcessing: Bool
    @Binding var showOriginal: Bool
    
    var displayImage: UIImage? {
        if generatedImage != nil {
            return showOriginal ? selectedImage : generatedImage
        }
        return selectedImage ?? templateImage
    }
    
    var hasGeneratedImage: Bool {
        generatedImage != nil
    }
    
    var body: some View {
        ZStack {
            // Image
            if let image = displayImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                // Placeholder
                VStack(spacing: 16) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 56))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Please select a photo")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.5))
                }
                .background(Color.black.opacity(0.3))
            }
            
            // Toggle switch overlay (bottom-left)
            if hasGeneratedImage && !isProcessing {
                VStack {
                    Spacer()
                    HStack {
                        ImageToggleSwitch(showOriginal: $showOriginal)
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FullScreenImageView(
        selectedImage: nil,
        generatedImage: nil,
        templateImage: nil,
        isProcessing: false,
        showOriginal: .constant(false)
    )
}
