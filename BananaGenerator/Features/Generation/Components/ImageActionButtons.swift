import SwiftUI

/// Action buttons for saving and sharing generated images
struct ImageActionButtons: View {
    let image: UIImage
    let onSave: () -> Void

    var body: some View {
        HStack {
            // Single capsule container with glass effect
            HStack {
                // Save button (icon only)
                Button(action: onSave) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 33, height: 33)
                }

                // Share button using native ShareLink
                ShareLink(
                    item: ShareableImage(image),
                    preview: SharePreview("Generated Image", image: Image(uiImage: image))
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 33, height: 33)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .glassEffect(in: .capsule)  // iOS 26 liquid glass effect
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    ImageActionButtons(
        image: UIImage(systemName: "photo.fill") ?? UIImage(),
        onSave: {
            print("Save button tapped")
        }
    )
    .background(Color.black)
    .preferredColorScheme(.dark)
}
