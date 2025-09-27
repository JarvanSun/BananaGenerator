import SwiftUI

/// Nebula-style dreamy loading background using a SwiftUI Shader (iOS 17+).
/// Keeps existing ParticleLoadingView intact; this is a drop-in alternative.
struct NebulaLoadingView: View {
    // Tuning params (safe defaults)
    var brightness: CGFloat = 1.05
    var saturation: CGFloat = 1.15
    var alpha: CGFloat = 0.95
    var speed: CGFloat = 0.10
    var seed: CGFloat = 0.37
    var overlayMaterial: Bool = true
    var overlayStrength: CGFloat = 1.0 // 0..1
    var blurRadius: CGFloat = 0.0 // extra Gaussian blur for dreamy haze
    // Gradient edge blur: center clear, edges more blurred
    var gradientEdgeBlurEnabled: Bool = false
    var edgeBlurRadius: CGFloat = 14
    var centerClearRadius: CGFloat = 0.38 // 0..1, relative to mask radius
    var edgeBlurFeather: CGFloat = 0.28 // 0..1, ramp width from clear to blurred
    var useAdditiveInDark: Bool = true

    @Environment(\.colorScheme) private var colorScheme
    // Fallback tick to ensure animation even if TimelineView stalls in Preview/hosting
    @State private var phase: CGFloat = 0
    private let displayTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            TimelineView(.periodic(from: .now, by: 1.0 / 60.0)) { _ in
                let t = phase
                ZStack {
                    let blend: BlendMode = (colorScheme == .dark && useAdditiveInDark) ? .plusLighter : .normal

                    // Base nebula layer (optionally softly blurred)
                    NebulaLayer(
                        time: t,
                        brightness: brightness,
                        saturation: saturation,
                        alpha: alpha,
                        speed: speed,
                        seed: seed
                    )
                    .compositingGroup()
                    .blur(radius: blurRadius, opaque: false)
                    .blendMode(blend)

                    // Edge-only blurred overlay for gradient blur effect
                    if gradientEdgeBlurEnabled {
                        NebulaLayer(
                            time: t,
                            brightness: brightness,
                            saturation: saturation,
                            alpha: alpha,
                            speed: speed,
                            seed: seed
                        )
                        .blur(radius: edgeBlurRadius, opaque: false)
                        .mask(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black, location: max(0, centerClearRadius)),
                                    .init(color: .white, location: min(1, centerClearRadius + edgeBlurFeather))
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: max(geo.size.width, geo.size.height) * 0.85
                            )
                        )
                        .opacity(0.95)
                        .compositingGroup()
                        .blendMode(blend)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    }

                    // Optional frosted overlay above nebula for extra haze
                    if overlayMaterial {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.75 * overlayStrength)
                            .mask(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .white, location: 0.0),
                                        .init(color: .white.opacity(0.9), location: 0.35),
                                        .init(color: .white.opacity(0.6), location: 0.60),
                                        .init(color: .white.opacity(0.0), location: 1.0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: max(geo.size.width, geo.size.height) * 0.65
                                )
                            )
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
            }
            .onReceive(displayTimer) { _ in
                phase += 1.0 / 60.0
            }
        }
    }
}

// MARK: - Private Nebula drawing layer
private struct NebulaLayer: View {
    var time: CGFloat
    var brightness: CGFloat
    var saturation: CGFloat
    var alpha: CGFloat
    var speed: CGFloat
    var seed: CGFloat

    var body: some View {
        Canvas { context, size in
            let shader = ShaderLibrary.nebula(
                .float2(.init(x: size.width, y: size.height)),
                .float(time * speed),
                .float(seed),
                .float(brightness),
                .float(saturation),
                .float(alpha)
            )
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .shader(shader))
        }
    }
}

#if DEBUG
// Simple demo container mirroring the existing example style
struct NebulaLoadingDemoView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                    .overlay(
                        NebulaLoadingView(
                            brightness: 1.15,
                            saturation: 1.25,
                            alpha: 0.98,
                            speed: 0.18,
                            seed: 0.42,
                            overlayMaterial: false,
                            overlayStrength: 0.85,
                            blurRadius: 6,
                            gradientEdgeBlurEnabled: true,
                            edgeBlurRadius: 16,
                            centerClearRadius: 0.36,
                            edgeBlurFeather: 0.32
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .opacity(isLoading ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.35), value: isLoading)
                    )

                if !isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)

                        Text("Click to start loading")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity)
                }
            }
            .frame(width: 340, height: 360)

            VStack {
                Spacer()
                Button(isLoading ? "Stop Loading" : "Start Loading") {
                    isLoading.toggle()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview("Nebula Loading") {
    NebulaLoadingDemoView()
}
#endif
