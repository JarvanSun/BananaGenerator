import SwiftUI

/// Reusable glass effect close button using iOS 26 native API
struct GlassCloseButton: View {
    let action: () -> Void
    var size: CGFloat = 44
    var iconSize: CGFloat = 16

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .glassEffect(in: .circle)
        }
    }
}

#Preview {
    GlassCloseButton(action: {})
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.gray)
}