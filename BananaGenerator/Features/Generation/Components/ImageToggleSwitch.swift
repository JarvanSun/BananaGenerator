import SwiftUI

/// Visual toggle switch for original/generated image with segmented control style
struct ImageToggleSwitch: View {
    @Binding var showOriginal: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showOriginal.toggle()
            }
        }) {
            ZStack {
                // Background capsule
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                // Sliding indicator without GeometryReader
                HStack(spacing: 0) {
                    if showOriginal {
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 45)
                        Spacer()
                            .frame(width: 45)
                    } else {
                        Spacer()
                            .frame(width: 45)
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 45)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showOriginal)
                
                // Icons
                HStack(spacing: 0) {
                    // Original photo icon
                    Image(systemName: "photo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(showOriginal ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .scaleEffect(showOriginal ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showOriginal)
                    
                    // Generated/effect icon
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(!showOriginal ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .scaleEffect(!showOriginal ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showOriginal)
                }
            }
            .frame(width: 90, height: 36)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    ImageToggleSwitch(showOriginal: .constant(false))
        .padding()
        .background(Color.black)
}