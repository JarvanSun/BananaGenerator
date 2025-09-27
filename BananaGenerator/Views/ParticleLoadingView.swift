import SwiftUI

struct ParticleLoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    // Configuration
    let particleCount = 320              // more particles
    let trailCount = 3                   // small motion trails
    let particleColor: Color = .accentColor
    
    var body: some View {
        TimelineView(.animation) { timeline in
            // Drive animation time from the timeline's date
            let time = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
            let useAdditive = (colorScheme == .dark)
            
            ZStack {
                // Slight dimming on light backgrounds to increase contrast
                if !useAdditive {
                    Color.black.opacity(0.10)
                }
                // Particle animation only (no text)
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let r = min(size.width, size.height) * 0.48 // adaptive radius to container

                    // Soft glow blending
                    context.addFilter(.blur(radius: 0.6))
                    
                    for i in 0..<particleCount {
                        drawParticle(
                            context: context,
                            center: center,
                            baseRadius: r,
                            index: i,
                            total: particleCount,
                            time: time,
                            useAdditive: useAdditive
                        )
                    }
                }
                .compositingGroup()
                .blendMode(useAdditive ? .plusLighter : .normal)
                .allowsHitTesting(false)
            }
        }
        // TimelineView invalidates frames automatically; no manual state needed
    }
    
    private func drawParticle(
        context: GraphicsContext,
        center: CGPoint,
        baseRadius: CGFloat,
        index: Int,
        total: Int,
        time: CGFloat,
        useAdditive: Bool
    ) {
        let progress = CGFloat(index) / CGFloat(total)

        // 3 interleaved layers with different scales and speeds
        let layer = index % 3
        let layerScale: CGFloat = (layer == 0 ? 1.0 : (layer == 1 ? 0.75 : 0.52))
        let rotationSpeed: CGFloat = (layer == 0 ? 1.10 : (layer == 1 ? -0.85 : 0.55))
        let wave = 0.22 * layerScale * baseRadius
        
        // Dynamic radius with wave + slight twist
        let radial = baseRadius * layerScale * (0.78 + 0.22 * sin(time * (1.6 + 0.15 * layerScale) + progress * .pi * 6))
        let radius = min(baseRadius * layerScale, radial + wave * sin(time * 2.0 + progress * .pi * 8))
        
        // Angle with subtle turbulence
        let angle = progress * .pi * 2 + time * rotationSpeed + 0.12 * sin(time * 1.3 + progress * .pi * 10)

        // Trails for motion blur effect
        for t in 0..<trailCount {
            let trailTime = time - CGFloat(t) * 0.035
            let decay = pow(0.62, Double(t))
            let trailAngle = progress * .pi * 2 + trailTime * rotationSpeed + 0.12 * sin(trailTime * 1.3 + progress * .pi * 10)
            let trailRadius = min(baseRadius * layerScale,
                                  baseRadius * layerScale * (0.78 + 0.22 * sin(trailTime * (1.6 + 0.15 * layerScale) + progress * .pi * 6))
                                  + wave * sin(trailTime * 2.0 + progress * .pi * 8))
            let x = center.x + trailRadius * cos(trailAngle)
            let y = center.y + trailRadius * sin(trailAngle)

            // Color cycles through the spectrum with time
            let hue = (Double(progress) + Double(time) * 0.05).truncatingRemainder(dividingBy: 1.0)
            let brightness = useAdditive ? 1.0 : 0.82
            let color = Color(hue: hue, saturation: 0.95, brightness: brightness, opacity: 1.0)

            // Size and alpha dynamics
            let baseSize: CGFloat = (layer == 0 ? 3.6 : (layer == 1 ? 3.0 : 2.4))
            let size = baseSize * (0.85 + 0.25 * cos(time * 2.0 + progress * .pi))
            let alphaBase = (layer == 0 ? 0.85 : (layer == 1 ? 0.65 : 0.5))
            let alpha = min(1.0, (alphaBase * (0.55 + 0.45 * sin(time * 2.4 + progress * .pi * 2)) * CGFloat(decay)) * (useAdditive ? 1.0 : 1.25))

            let particleRect = CGRect(x: x - size / 2, y: y - size / 2, width: size, height: size)
            context.fill(Path(ellipseIn: particleRect), with: .color(color.opacity(alpha)))

            // Occasional glow flares
            if index % 18 == 0 && t == 0 {
                let glowSize = size * 5
                let glowRect = CGRect(x: x - glowSize / 2, y: y - glowSize / 2, width: glowSize, height: glowSize)
                let gradient = Gradient(colors: [
                    color.opacity(alpha * 0.32),
                    color.opacity(0)
                ])
                context.fill(
                    Path(ellipseIn: glowRect),
                    with: .radialGradient(gradient,
                                          center: .init(x: x, y: y),
                                          startRadius: 0,
                                          endRadius: glowSize / 2)
                )
            }
        }
    }
}

// Example View for Testing
struct ParticleLoadingExampleView: View {
    @State private var isLoading = false
    @State private var loadingTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
//            Color(.systemGroupedBackground)
//                .ignoresSafeArea()
//            
            VStack(spacing: 40) {
                Text("Particle Loading Animation Demo")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                
                // Main content area
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .frame(width: 350, height: 400)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    if isLoading {
                        // Loading overlay with particle animation
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                ParticleLoadingView()
                            )
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor)
                            
                            Text("Click button below to start")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(width: 350, height: 400)
                
                // Control button
                Button(action: {
                    if isLoading {
                        // Cancel loading
                        loadingTask?.cancel()
                        isLoading = false
                    } else {
                        // Start loading
                        isLoading = true
                        loadingTask = Task {
                            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                            if !Task.isCancelled {
                                await MainActor.run {
                                    isLoading = false
                                }
                            }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isLoading ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 20))
                        
                        Text(isLoading ? "Stop Loading" : "Start Loading (10s)")
                            .font(.system(.headline, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        Capsule()
                            .fill(isLoading ? Color.red : Color.accentColor)
                    )
                }
                .animation(.easeInOut, value: isLoading)
            }
        }
    }
}

// Preview
#Preview("Particle Loading") {
    ZStack {
        Color(.systemBackground)
        
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .frame(width: 300, height: 300)
            .overlay(
                ParticleLoadingView()
            )
    }
}

#Preview("Example View") {
    ParticleLoadingExampleView()
}
