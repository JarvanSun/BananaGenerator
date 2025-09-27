import SwiftUI

/// Host view that wraps HistoryGridView with NavigationStack
struct HistoryGridHostView: View {
    var body: some View {
        NavigationStack {
            HistoryGridView()
        }
    }
}

// MARK: - Preview
#Preview {
    HistoryGridHostView()
}