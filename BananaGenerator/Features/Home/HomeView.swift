import SwiftUI
import Playgrounds

/// Main home view displaying recent photos and templates
/// Inspired by Grok Imagine interface
struct HomeView: View {
    @State private var inputText: String = ""
    @State private var historyManager = GenerationHistoryManager.shared
    @State private var showHistory = false
    @State private var navigationData: GenerationNavigation?

    @Namespace private var nameSpace
    
    var body: some View {
        // Main content area - iOS automatically manages space for toolbar
        ScrollView {
            VStack(spacing: 32) {
                // Recent Photos Section
                RecentPhotosCard(onPhotoSelected: { image, template in
                    navigateToGeneration(template: template, image: image, transitionID: "recent-photo-transition")
                })

                // Templates Grid Section
                TemplateGrid(
                    onTemplateSelected: { template in
                        navigateToGeneration(template: template, transitionID: "template-\(template.id)")
                    },
                    namespace: nameSpace
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationTitle("Nano Banana")
//        .toolbar {
//            ToolbarItem(placement: .bottomBar) {
//                HistoryThumbnailButton(
//                    latestImage: historyManager.latestImage?.generatedImage,
//                    action: {
//                        showHistory = true
//                    }
//                )
//            }
//            ToolbarSpacer(.flexible, placement: .bottomBar)
//        }
        .fullScreenCover(isPresented: $showHistory, content: {
            HistoryGridHostView()
                .navigationTransition(.zoom(sourceID: "history-transition-id", in: nameSpace))
        })
        // Use item: so presentation is driven by navigationData non-nil
        .fullScreenCover(item: $navigationData) { data in
            ImageGenerationView(template: data.template, initialImage: data.image)
                .presentationBackground(Color.black)
                .navigationTransition(.zoom(sourceID: data.transitionID, in: nameSpace))
        }
    }

    private func handleSubmit() {
        guard !inputText.isEmpty else { return }

        // Phase 4: Create custom generation with prompt
        // For now, navigate to first template as placeholder
        if let firstTemplate = Template.allTemplates.first {
            navigateToGeneration(template: firstTemplate)
        }

        // Clear input
        inputText = ""
    }
    
    private func handleMicrophone() {
        // Phase 4: Implement voice input
    }

    // Unified navigation handler for child components
    private func navigateToGeneration(template: Template, image: UIImage? = nil, transitionID: String = "default-transition") {
        navigationData = GenerationNavigation(template: template, image: image, transitionID: transitionID)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
