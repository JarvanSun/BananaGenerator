import SwiftUI

/// Generate button with processing state
struct GenerateButton: View {
    let isProcessing: Bool
    let canGenerate: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 44, height: 44)
            .glassCircleStyleCompat()
        }
        .disabled(!canGenerate || isProcessing)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Normal state
        GenerateButton(
            isProcessing: false,
            canGenerate: true,
            action: {}
        )

        // Processing state
        GenerateButton(
            isProcessing: true,
            canGenerate: true,
            action: {}
        )

        // Disabled state
        GenerateButton(
            isProcessing: false,
            canGenerate: false,
            action: {}
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}