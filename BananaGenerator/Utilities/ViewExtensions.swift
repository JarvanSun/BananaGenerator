import SwiftUI

// MARK: - Size & Frame Observation

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

extension View {
    /// Observe the laid-out size of a view without affecting layout.
    func onSizeChange(_ action: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }

    /// Observe the laid-out frame in a given coordinate space.
    func onFrameChange(in space: CoordinateSpace = .local, _ action: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: FramePreferenceKey.self, value: proxy.frame(in: space))
            }
        )
        .onPreferenceChange(FramePreferenceKey.self, perform: action)
    }
}

// MARK: - Glass Button Style

/// iOS 26 Liquid Glass button style modifier using native glassEffect API
struct GlassButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .glassEffect(in: .capsule)
    }
}

extension View {
    /// Apply iOS 26 native glass button styling
    func glassButtonStyle() -> some View {
        modifier(GlassButtonStyle())
    }
}

// MARK: - Compatibility Wrappers

extension View {
    /// Compatible glass circle style using iOS 26 glassEffect API
    func glassCircleStyleCompat() -> some View {
        self.glassEffect(in: .circle)
    }
    
    /// Applies a unified rounded thumbnail style: clips to a rounded rect and adds a matching inside stroke.
    func roundedThumbnail(cornerRadius: CGFloat, lineWidth: CGFloat, color: Color) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(color, lineWidth: lineWidth)
            )
    }
}
