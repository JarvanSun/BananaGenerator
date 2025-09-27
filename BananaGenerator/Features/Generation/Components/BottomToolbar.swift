import SwiftUI
import PhotosUI

/// Fixed bottom toolbar for image generation
struct BottomToolbar: View {
    @Bindable var viewModel: GenerationViewModel
    @State private var isKeyboardActive = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // History button (left) - only show when keyboard is not active
            if !isKeyboardActive {
                HistoryThumbnailButton(
                    latestImage: viewModel.historyManager.latestImage?.generatedImage,
                    action: { viewModel.showHistory = true }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }

            // Adaptive prompt input field with integrated photo picker (center, flexible)
            AdaptivePromptField(
                text: $viewModel.customPrompt,
                selectedItem: $viewModel.selectedItem,
                isKeyboardActive: $isKeyboardActive
            )
            .frame(maxWidth: .infinity)

            // Generate button (right)
            GenerateButton(
                isProcessing: viewModel.isProcessing,
                canGenerate: viewModel.canGenerate,
                action: {
                    viewModel.generateImage()
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.85))
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isKeyboardActive)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomToolbar(viewModel: GenerationViewModel())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
