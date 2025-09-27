import SwiftUI

/// Host view for the Home feature
/// Contains NavigationStack for navigation bar display
/// Uses fullScreenCover for navigation to ImageGenerationView
struct HomeHostView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .preferredColorScheme(.dark)
        .tint(.white)
    }
}

#Preview {
    HomeHostView()
}
