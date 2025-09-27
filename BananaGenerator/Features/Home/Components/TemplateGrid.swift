import SwiftUI

/// Template grid component with section-based organization
/// Displays templates grouped by categories
struct TemplateGrid: View {
    let onTemplateSelected: (Template) -> Void
    let namespace: Namespace.ID

    private let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Main header
            Text("AI Effects")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Template sections
            ForEach(TemplateSection.allSections) { section in
                templateSection(section)
            }
        }
    }

    private func templateSection(_ section: TemplateSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.orange)

                Text(section.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()
            }

            // Section grid
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(section.templates) { template in
                    templateCard(template)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func templateCard(_ template: Template) -> some View {
        Button(action: {
            onTemplateSelected(template)
        }) {
            // Template image with 4:3 ratio
            Image(template.coverImageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(4/3, contentMode: .fit)
                .clipped()
                .overlay(alignment: .bottomTrailing, content: {
                    TemplateActionButton().padding(8)
                })
        }
        .matchedTransitionSource(id: "template-\(template.id)", in: namespace)
    }
}

#Preview {
    HomeView()
}
