import SwiftUI
import QuickLook

/// Grid view for browsing generation history
struct HistoryGridView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var historyManager = GenerationHistoryManager.shared
    @State private var selectedURL: URL?
    @State private var previewURLs: [URL] = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(Array(historyManager.generatedImages.enumerated()), id: \.offset) { (idx, item) in
                    Button {
                        // Set selected URL to trigger QuickLook
                        if idx < previewURLs.count {
                            selectedURL = previewURLs[idx]
                        }
                    } label: {
                        HistoryGridItemView(image: item.generatedImage)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") { dismiss() }
            }
        }
        .task {
            await prepareURLs()
        }
        .quickLookPreview($selectedURL, in: previewURLs)
    }
    
    private func prepareURLs() async {
        let images = historyManager.generatedImages
        let tempDir = FileManager.default.temporaryDirectory
        
        var urls: [URL] = []
        for (idx, item) in images.enumerated() {
            guard let img = item.generatedImage,
                  let data = img.jpegData(compressionQuality: 0.9) else { continue }
            
            let url = tempDir.appendingPathComponent("preview_\(idx).jpg")
            do {
                try data.write(to: url)
                urls.append(url)
            } catch {
                print("❌ Failed to write preview image: \(error)")
            }
        }
        
        self.previewURLs = urls
    }
}

// MARK: - Preview
#Preview("History Grid - Empty") {
    HistoryGridView()
}

#Preview("History Grid - With Items") {
    // Create mock history manager with sample data
    let mockManager = GenerationHistoryManager.shared
    // Note: In real preview, you'd inject mock data
    return HistoryGridView()
}
