import SwiftUI
import PhotosUI

/// Adaptive prompt field that naturally expands with content
struct AdaptivePromptField: View {
    @Binding var text: String
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var isKeyboardActive: Bool

    @FocusState private var isFocused: Bool

    private let placeholder = "Enter text to generate image"

    var body: some View {
        HStack(spacing: 0) {
            // Photo picker button - only show when keyboard is not active
            if !isFocused {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .glassEffect(in: .circle)
                }
                .padding(.leading, 1)
                .padding(.vertical, 1)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }

            // Adaptive input field - always vertical axis with natural expansion
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(isFocused ? 1...10 : 1...1)  // Single line when unfocused
                .foregroundColor(.white)
                .font(.system(size: 17))
                .focused($isFocused)
                .padding(.leading, isFocused ? 12 : 4)
                .padding(.trailing, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44, maxHeight: isFocused ? nil : 44)  // Fixed height when unfocused
        }
        .background(fieldBackground)
        .onChange(of: isFocused) { oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isKeyboardActive = newValue
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
        .onAppear {
            // Ensure initial state is correct
            isKeyboardActive = false
        }
    }

    // MARK: - Subviews

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        Color.white.opacity(isFocused ? 0.25 : 0.15),
                        lineWidth: 0.5
                    )
            )
    }
}

#Preview("Adaptive Prompt Field") {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var selectedItem: PhotosPickerItem?
        @State private var isKeyboardActive = false

        var body: some View {
            VStack(spacing: 20) {
                Text("Keyboard Active: \(isKeyboardActive ? "Yes" : "No")")
                    .foregroundColor(.white)
                    .font(.headline)

                AdaptivePromptField(
                    text: $text,
                    selectedItem: $selectedItem,
                    isKeyboardActive: $isKeyboardActive
                )
                .padding()

                Button("Dismiss Keyboard") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .foregroundColor(.white)
                .padding()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}
