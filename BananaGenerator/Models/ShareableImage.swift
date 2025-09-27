import SwiftUI
import CoreTransferable

/// Wrapper for UIImage to make it conform to Transferable protocol for ShareLink
struct ShareableImage: Transferable {
    let uiImage: UIImage

    init(_ uiImage: UIImage) {
        self.uiImage = uiImage
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { shareableImage in
            guard let pngData = shareableImage.uiImage.pngData() else {
                throw ShareableImageError.conversionFailed
            }
            return pngData
        }
        .suggestedFileName("BananaGenerated.png")
    }
}

enum ShareableImageError: Error {
    case conversionFailed
}

#Preview {
    VStack {
        if let image = UIImage(systemName: "photo") {
            ShareLink(item: ShareableImage(image),
                     preview: SharePreview("Generated Image", image: Image(systemName: "photo"))) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
    .padding()
}
