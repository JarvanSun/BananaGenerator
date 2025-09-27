import SwiftUI

/// History thumbnail button with 30-degree rotation and glass effect
struct HistoryThumbnailButton: View {
    let latestImage: UIImage?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let image = latestImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(width: 36, height: 36)
            .roundedThumbnail(cornerRadius: 8, lineWidth: 1.5, color: .white)
            .rotationEffect(Angle(degrees: -20))
            .padding(.bottom, 4)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        // Preview with sample image
        HistoryThumbnailButton(
            latestImage: UIImage(systemName: "photo.fill"),
            action: { print("History tapped") }
        )
        
        // Preview without image
        HistoryThumbnailButton(
            latestImage: nil,
            action: { print("History tapped") }
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
