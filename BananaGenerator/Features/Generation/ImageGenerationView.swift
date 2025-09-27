import SwiftUI
import PhotosUI

/// Modern image generation view with full-screen image display
struct ImageGenerationView: View {
    @State private var viewModel: GenerationViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(template: Template, initialImage: UIImage?) {
        let vm = GenerationViewModel()
        vm.template = template
        if let image = initialImage {
            vm.setSelectedImage(image)
        }
        _viewModel = State(initialValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            contentView
                .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    var contentView: some View {
        ScrollView {
            // Main content
            VStack(spacing: 0) {
                // Full-screen image section (top half)
                FullScreenImageView(
                    selectedImage: viewModel.selectedImage,
                    generatedImage: viewModel.generatedImage,
                    templateImage: UIImage(named: viewModel.template?.coverImageName ?? ""),
                    isProcessing: viewModel.isProcessing,
                    showOriginal: $viewModel.showOriginal
                )
                
                // Action buttons (Save/Share) - below image
                if let displayImage = viewModel.generatedImage ?? viewModel.selectedImage {
                    HStack {
                        ImageActionButtons(
                            image: displayImage,
                            onSave: {
                                viewModel.saveImage()
                            }
                        )
                        Spacer()
                    }
                }
                
                // Template selector
                TemplateSelector(
                    selectedTemplate: viewModel.template ?? TemplateSection.allTemplatesFlatMapped.first!,
                    onTemplateSelected: { newTemplate in
                        viewModel.template = newTemplate
                        print("Template changed to: \(newTemplate.name)")
                    }
                )
                .padding(.vertical, 20)

                // Bottom padding to prevent content being hidden by toolbar
                // Toolbar height ~72 (48 content + 12 top padding + 12 bottom padding)
                Color.clear
                    .frame(height: 80)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            BottomToolbar(viewModel: viewModel)
        }
        .overlay(alignment: .topLeading) {
            GlassCloseButton(action: { dismiss() })
                .padding(.top, 10)
                .padding(.leading, 20)
        }
        .onAppear {
            print("ImageGenerationView appeared with template: \(viewModel.template?.name ?? "none")")
        }
        .alert("Saved Successfully", isPresented: $viewModel.showingSaveAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(viewModel.saveAlertMessage)
            }
        )
        .sheet(isPresented: $viewModel.showHistory) {
            HistoryGridHostView()
        }
    }
}

#Preview {
    ImageGenerationView(template: TemplateSection.allTemplatesFlatMapped.first ?? Template.toysTemplates[0], initialImage: nil)
        .preferredColorScheme(.dark)
}
