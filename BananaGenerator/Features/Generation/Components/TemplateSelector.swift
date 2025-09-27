import SwiftUI

// MARK: - Main Component

/// Horizontal scrollable template selector with sections
struct TemplateSelector: View {
    let selectedTemplate: Template
    let onTemplateSelected: (Template) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TemplateSelectorHeader()

            ScrollableTemplateList(
                selectedTemplate: selectedTemplate,
                onTemplateSelected: onTemplateSelected
            )
        }
    }
}

// MARK: - Subcomponents

/// Header for the template selector
private struct TemplateSelectorHeader: View {
    var body: some View {
        Text("Select Effect")
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
    }
}

/// Scrollable list of template sections
private struct ScrollableTemplateList: View {
    let selectedTemplate: Template
    let onTemplateSelected: (Template) -> Void

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                TemplateSectionsContent(
                    selectedTemplate: selectedTemplate,
                    onTemplateSelected: onTemplateSelected
                )
                .padding(.horizontal, 20)
            }
            .onAppear {
                scrollToSelectedTemplate(using: scrollProxy)
            }
            .onChange(of: selectedTemplate.id) {
                scrollToSelectedTemplate(using: scrollProxy, animated: true)
            }
        }
    }

    private func scrollToSelectedTemplate(using proxy: ScrollViewProxy, animated: Bool = false) {
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(selectedTemplate.id, anchor: .leading)
            }
        } else {
            // Delay to ensure layout is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    proxy.scrollTo(selectedTemplate.id, anchor: .leading)
                }
            }
        }
    }
}

/// Content container for all template sections
private struct TemplateSectionsContent: View {
    let selectedTemplate: Template
    let onTemplateSelected: (Template) -> Void

    var body: some View {
        HStack(spacing: 24) {
            ForEach(TemplateSection.allSections) { section in
                TemplateSectionView(
                    section: section,
                    selectedTemplate: selectedTemplate,
                    onTemplateSelected: onTemplateSelected
                )
            }
        }
    }
}

/// Individual template section view
private struct TemplateSectionView: View {
    let section: TemplateSection
    let selectedTemplate: Template
    let onTemplateSelected: (Template) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(
                icon: section.icon,
                title: section.title
            )

            TemplateSectionGrid(
                templates: section.templates,
                selectedTemplate: selectedTemplate,
                onTemplateSelected: onTemplateSelected
            )
        }
    }
}

/// Section header with icon and title
private struct SectionHeaderView: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white.opacity(0.6))
    }
}

/// Grid of templates within a section
private struct TemplateSectionGrid: View {
    let templates: [Template]
    let selectedTemplate: Template
    let onTemplateSelected: (Template) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(templates) { template in
                TemplateThumbnail(
                    template: template,
                    isSelected: template.id == selectedTemplate.id,
                    onTap: {
                        if template.id != selectedTemplate.id {
                            onTemplateSelected(template)
                        }
                    }
                )
                .id(template.id) // Add unique ID for scrolling
            }
        }
    }
}

// MARK: - Template Thumbnail

/// Individual template thumbnail
struct TemplateThumbnail: View {
    let template: Template
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                TemplateThumbnailImage(
                    imageName: template.coverImageName,
                    isSelected: isSelected
                )

                TemplateThumbnailLabel(
                    name: template.name,
                    isSelected: isSelected
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Template thumbnail image with selection overlay
private struct TemplateThumbnailImage: View {
    let imageName: String
    let isSelected: Bool

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 60, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.white : Color.clear,
                        lineWidth: 2
                    )
            )
    }
}

/// Template thumbnail label
private struct TemplateThumbnailLabel: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        Text(name)
            .font(.caption)
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .lineLimit(1)
            .frame(width: 60)
    }
}

// MARK: - Preview

#Preview {
    TemplateSelector(
        selectedTemplate: TemplateSection.allTemplatesFlatMapped.first ?? Template.toysTemplates[0],
        onTemplateSelected: { _ in }
    )
    .padding(.vertical)
    .background(Color.black)
    .preferredColorScheme(.dark)
}