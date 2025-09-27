import SwiftUI

/// Reusable grid item view for displaying history thumbnails
struct HistoryGridItemView: View {
    let image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview
#Preview("History Grid Item - With Image") {
    HistoryGridItemView(image: UIImage(systemName: "photo"))
        .frame(width: 120, height: 120)
        .padding()
}

#Preview("History Grid Item - Placeholder") {
    HistoryGridItemView(image: nil)
        .frame(width: 120, height: 120)
        .padding()
}