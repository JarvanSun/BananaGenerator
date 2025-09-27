import SwiftUI

/// Navigation data for presenting ImageGenerationView
/// Combines template and optional image to ensure atomic state updates
struct GenerationNavigation: Identifiable {
    let id = UUID()
    let template: Template
    let image: UIImage?
    let transitionID: String
}