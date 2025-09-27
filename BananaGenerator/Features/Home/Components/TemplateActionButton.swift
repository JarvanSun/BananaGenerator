import SwiftUI

/// Action button overlay for template cards with iOS 26 liquid glass effect
struct TemplateActionButton: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "play.fill")
                .font(.caption)
            
            Text("Use Template")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.black.opacity(0.6)))
        .glassEffect(in: .capsule)  // iOS 26 liquid glass effect
        
    }
}

#Preview {
    HomeView()
}

#Preview {
    VStack(spacing: 20) {
        // Preview on dark background
        TemplateActionButton()
        
        // Preview over an image
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 150)
            .foregroundColor(.gray)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        TemplateActionButton()
                    }
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                }
            )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
